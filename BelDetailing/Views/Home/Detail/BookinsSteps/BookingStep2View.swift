import SwiftUI
import RswiftResources

struct BookingStep2View: View {

    let service: Service
    let detailer: Detailer
    let date: Date
    let time: String
    let engine: Engine

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility

    @State var fullName: String = ""
    @State var phone: String = ""
    @State var email: String = ""
    @State var notes: String = ""

    @State private var goToStep3: Bool = false

    var body: some View {

        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // === FIXED BACK BUTTON ===
                CustomBackButton {
                    dismiss()
                }

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 24) {

                        Spacer().frame(height: 20)

                        // === BIG WHITE CARD (FULL WIDTH LIKE MAQUETTE 2) ===
                        VStack(alignment: .leading, spacing: 28) {

                            serviceSummaryCard
                            userInfoSection

                        }
                        .padding(24)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                        .padding(.horizontal, 12)

                        Spacer().frame(height: 40)
                    }
                }
            }

            // === FIXED CONTINUE BUTTON ===
            VStack {
                Spacer()
                Button {
                    goToStep3 = true
                } label: {
                    Text(R.string.localizable.bookingContinue())
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .cornerRadius(40)
                }
                .padding(.horizontal, 24)
                .padding(.bottom,20)   // 👈 avant: 20 → bouton plus bas, plus loin des notes
            }

            // === HIDDEN NAVIGATION ===
            NavigationLink(
                destination: destinationStep3,
                isActive: $goToStep3
            ) { EmptyView() }
        }

        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { tabBarVisibility.isHidden = true }
        .onDisappear { tabBarVisibility.isHidden = false }
    }

    private var destinationStep3: some View {
        BookingStep3View(
            service: service,
            detailer: detailer,
            date: date,
            time: time,
            engine: engine,
            fullName: fullName,
            phone: phone,
            email: email,
            notes: notes
        )
        .environmentObject(tabBarVisibility)
    }
}
