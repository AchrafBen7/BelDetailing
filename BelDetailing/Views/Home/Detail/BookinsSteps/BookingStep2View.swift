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
    
    @State private var createdBookingId: String?
    @State var fullName: String = ""
    @State var phone: String = ""
    @State var email: String = ""
    @State var notes: String = ""
    @State var address: String = ""

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var goToStep3: Bool = false

    // ✅ Tous les champs requis + format email/téléphone
    private var canContinue: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        phone.isValidPhone &&
        email.isValidEmail &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty
    }

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

                        // === BIG WHITE CARD ===
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
                    if canContinue {
                        goToStep3 = true
                    } else {
                        // Haptique
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

                        if fullName.isEmpty || phone.isEmpty || email.isEmpty || address.isEmpty {
                            alertMessage = R.string.localizable.bookingMissingFields()
                        } else if !email.isValidEmail {
                            alertMessage = R.string.localizable.bookingInvalidEmail()
                        } else if !phone.isValidPhone {
                            alertMessage = R.string.localizable.bookingInvalidPhone()
                        } else {
                            alertMessage = R.string.localizable.bookingMissingFields()
                        }

                        showAlert = true
                    }
                } label: {
                    Text(R.string.localizable.bookingContinue())
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(canContinue ? Color.black : Color.gray.opacity(0.4))
                        .cornerRadius(40)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(R.string.localizable.errorTitle()),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }

            // === HIDDEN NAVIGATION ===
            NavigationLink(
                destination: destinationStep3,
                isActive: $goToStep3
            ) {
                EmptyView()
            }
        } // ✅ FERMETURE DU ZSTACK

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
            address: address,
            notes: notes,
            bookingId: createdBookingId ?? ""
        )
        .environmentObject(tabBarVisibility)
    }
    
    @MainActor
    func createBookingThenGo() async {

        let payload: [String: Any] = [
            "provider_id": detailer.id,
            "service_id": service.id,
            "date": date.toISODateString(),
            "start_time": time,
            "end_time": time, // si tu n’as pas encore logic endTime
            "address": address
        ]

    }

}


// MARK: - Validation helpers

extension String {
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    var isValidPhone: Bool {
        let digits = self.filter { $0.isNumber }
        return digits.count >= 8 && digits.count <= 12
    }
}
