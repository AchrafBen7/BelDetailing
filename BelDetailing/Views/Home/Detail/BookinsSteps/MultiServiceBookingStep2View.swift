//
//  MultiServiceBookingStep2View.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources

struct MultiServiceBookingStep2View: View {
    let services: [Service]
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

    // Calcul du prix total
    private var totalPrice: Double {
        let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
        return services.reduce(0) { total, service in
            let adjustedPrice = engine.vehiclePricingService.calculateAdjustedPrice(
                basePrice: service.price,
                vehicleType: customerVehicleType
            )
            return total + adjustedPrice
        }
    }

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

                        // === SERVICES SUMMARY CARD ===
                        servicesSummaryCard

                        // === TOTAL PRICE CARD ===
                        totalPriceCard

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

    // MARK: - Services Summary Card
    private var servicesSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 40, height: 40)
                    Image(systemName: "list.bullet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("Services sélectionnés")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 12) {
                ForEach(services) { service in
                    let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
                    let adjustedPrice = engine.vehiclePricingService.calculateAdjustedPrice(
                        basePrice: service.price,
                        vehicleType: customerVehicleType
                    )
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(service.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("\(service.durationMinutes) min")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(adjustedPrice))€")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 8)
                    
                    if service.id != services.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }

    // MARK: - Total Price Card
    private var totalPriceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Text("\(Int(totalPrice))€")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Personal Information Card
    private var personalInformationCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            // TITLE
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text("Informations personnelles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }

            // FULL NAME
            inputField(
                title: "NOM COMPLET",
                text: $fullName,
                placeholder: "Jean Dupont"
            )

            // PHONE
            inputField(
                title: "TÉLÉPHONE",
                text: $phone,
                placeholder: "+32 2 123 45 67",
                keyboard: .phonePad
            )

            // EMAIL
            inputField(
                title: "EMAIL",
                text: $email,
                placeholder: "jean.dupont@email.com",
                keyboard: .emailAddress
            )
            
            // ADDRESS
            inputField(
                title: "ADRESSE",
                text: $address,
                placeholder: "Rue de la Paix 123, 1000 Bruxelles"
            )

            // NOTES (OPTIONAL)
            VStack(alignment: .leading, spacing: 8) {
                Text("NOTES (OPTIONNEL)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Instructions particulières, accès...")
                            .foregroundColor(.gray)
                            .padding(.leading, 16)
                            .padding(.top, 20)
                    }
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
    }

    // MARK: - Input Field Helper
    private func inputField(title: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .padding(.vertical, 14)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
    }

    // MARK: - DESTINATION STEP 3
    private var destinationStep3: some View {
        MultiServiceBookingStep3View(
            services: services,
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
}


