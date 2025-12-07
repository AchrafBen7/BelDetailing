import SwiftUI
import RswiftResources
import StripePaymentSheet

struct BookingStep3View: View {
    let service: Service
    let detailer: Detailer
    let date: Date
    let time: String
    let engine: Engine
    let fullName: String
    let phone: String
    let email: String
    let address: String
    let notes: String
    let bookingId: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @EnvironmentObject var mainTabSelection: MainTabSelection
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    @State var goToConfirmation = false
    @State var selectedPayment: Payment = .card
    @State var promoCode: String = ""

    @State var isProcessingPayment = false
    @State var paymentAlertMessage: String?
    @State var showPaymentAlert = false

    let cardInset: CGFloat = 20

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                CustomBackButton {
                    dismiss()
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        Spacer().frame(height: 20)

                        recapSection
                        paymentSection
                        promoCodeSection
                        notesSection
                        priceBreakdownSection
                        termsSection

                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .overlay(alignment: .bottom) {
            VStack {
                confirmButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .background(
                Color(.systemGroupedBackground)
                    .opacity(0.98)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .background(
            NavigationLink(
                destination: BookingConfirmedView(
                    engine: engine,
                    tabSelection: $mainTabSelection.currentTab
                )
                .environmentObject(tabBarVisibility),
                isActive: $goToConfirmation
            ) { EmptyView() }
        )
        // Loader UNIQUEMENT pendant la création de la booking
        .overlay {
            if isProcessingPayment {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView("Processing booking...")
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                    )
            }
        }
        .alert(isPresented: $showPaymentAlert) {
                    Alert(
                        title: Text("Payment"),
                        message: Text(paymentAlertMessage ?? "Unknown error"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .tabBar)
                .onAppear { tabBarVisibility.isHidden = true }
                .onDisappear { tabBarVisibility.isHidden = false }
    }
}

extension BookingStep3View {
    func showAlert(_ message: String) {
        paymentAlertMessage = message
        showPaymentAlert = true
    }
}
