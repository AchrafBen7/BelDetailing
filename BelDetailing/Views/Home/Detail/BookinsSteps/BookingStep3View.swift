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
    @State var confirmationData: BookingConfirmationData?
    @State var selectedPayment: Payment = .card
    @State var promoCode: String = ""

    @State var isProcessingPayment = false
    @State var paymentAlertMessage: String?
    @State var showPaymentAlert = false
    
    // Prix calculé
    @State  var calculatedTransportFee: Double = 0
    @State  var calculatedTransportDistanceKm: Double? = nil
    @State  var isCalculatingTransportFee = false
    @State  var transportFeeError: String? = nil // Message d'erreur si distance > 60 km ou service non disponible

    let cardInset: CGFloat = 20

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // === HEADER ===
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
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
                    tabSelection: $mainTabSelection.currentTab,
                    confirmationData: confirmationData
                )
                .environmentObject(tabBarVisibility),
                isActive: $goToConfirmation
            ) { EmptyView() }
        )
        // Loader UNIQUEMENT pendant la création de la booking
        .overlay {
            if isProcessingPayment {
                ZStack {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        
                        Text(R.string.localizable.commonLoading())
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.95))
                            .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
                    )
                }
            }
        }
        .alert(isPresented: $showPaymentAlert) {
            Alert(
                title: Text(R.string.localizable.errorPaymentFailedTitle()),
                message: Text(paymentAlertMessage ?? R.string.localizable.errorPaymentFailedMessage()),
                dismissButton: .default(Text(R.string.localizable.commonOk()))
            )
        }
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .tabBar)
                .onAppear {
                    tabBarVisibility.isHidden = true
                    Task {
                        await calculateTransportFee()
                    }
                }
                .onDisappear { tabBarVisibility.isHidden = false }
    }
}

extension BookingStep3View {
    func showAlert(_ message: String) {
        paymentAlertMessage = message
        showPaymentAlert = true
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Back button
                Button(action: { dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                // Step indicator
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        // Step 1 - completed
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                        
                        // Step 2 - completed
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                        
                        // Step 3 - active
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                    }
                    
                    Text("Étape 3/3")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Spacer pour équilibrer
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 12)
            
            // Title
            HStack {
                Text(R.string.localizable.bookingPaymentTitle())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}
