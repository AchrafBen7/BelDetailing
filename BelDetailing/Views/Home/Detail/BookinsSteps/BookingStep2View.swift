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
                // === HEADER ===
                headerSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)

                        // === SERVICE DETAILS CARD ===
                        serviceDetailsCard

                        // === PERSONAL INFORMATION CARD ===
                        personalInformationCard

                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }

            // === FIXED CONTINUE BUTTON ===
            VStack {
                Spacer()
                Button {
                    if canContinue {
                        goToStep3 = true
                    } else {
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
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(canContinue ? Color.black : Color.gray.opacity(0.4))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            tabBarVisibility.isHidden = true
            prefillUserData()
        }
        .onDisappear { tabBarVisibility.isHidden = false }
    }
    
    // MARK: - Prefill User Data
    private func prefillUserData() {
        guard let user = AppSession.shared.user else { return }
        
        // Full name from customer profile
        if let customerProfile = user.customerProfile {
            let firstName = customerProfile.firstName.isEmpty ? "" : customerProfile.firstName
            let lastName = customerProfile.lastName.isEmpty ? "" : customerProfile.lastName
            let fullNameValue = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            if !fullNameValue.isEmpty && fullName.isEmpty {
                fullName = fullNameValue
            }
            
            // Address
            if let defaultAddress = customerProfile.defaultAddress, !defaultAddress.isEmpty && address.isEmpty {
                address = defaultAddress
            }
        }
        
        // Phone
        if let userPhone = user.phone, !userPhone.isEmpty && phone.isEmpty {
            phone = userPhone
        }
        
        // Email
        if !user.email.isEmpty && email.isEmpty {
            email = user.email
        }
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
                        
                        // Step 2 - active
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                        
                        // Step 3 - inactive
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    
                    Text("Étape 2/3")
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
                Text("Vos coordonnées")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
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

