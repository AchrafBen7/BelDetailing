//
//  MultiServiceBookingStep3View.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI
import RswiftResources
import StripePaymentSheet
import CoreLocation

struct MultiServiceBookingStep3View: View {
    let services: [Service]
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
    @State var calculatedTransportFee: Double = 0
    @State var calculatedTransportDistanceKm: Double? = nil
    @State var isCalculatingTransportFee = false
    @State var transportFeeError: String? = nil

    let cardInset: CGFloat = 20
    
    // Calcul du prix total des services
    private var totalServicesPrice: Double {
        let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
        return services.reduce(0) { total, service in
            let adjustedPrice = engine.vehiclePricingService.calculateAdjustedPrice(
                basePrice: service.price,
                vehicleType: customerVehicleType
            )
            return total + adjustedPrice
        }
    }
    
    // Prix total avec transport
    private var totalPrice: Double {
        totalServicesPrice + calculatedTransportFee
    }
    
    // Montant à payer selon la méthode
    private var amountToPay: Double {
        selectedPayment == .cash ? totalPrice * 0.20 : totalPrice
    }

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

// MARK: - Extensions

extension MultiServiceBookingStep3View {
    func showAlert(_ message: String) {
        paymentAlertMessage = message
        showPaymentAlert = true
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
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
                
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Circle().fill(Color.black).frame(width: 8, height: 8)
                        Circle().fill(Color.black).frame(width: 8, height: 8)
                        Circle().fill(Color.black).frame(width: 8, height: 8)
                    }
                    Text("Étape 3/3")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 12)
            
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
    
    // MARK: - Recap Section
    var recapSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(R.string.localizable.bookingSummary())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 16) {
                // Services list
                ForEach(services) { service in
                    let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
                    let adjustedPrice = engine.vehiclePricingService.calculateAdjustedPrice(
                        basePrice: service.price,
                        vehicleType: customerVehicleType
                    )
                    
                    HStack(alignment: .top, spacing: 16) {
                        // Service image
                        AsyncImage(url: URL(string: service.imageUrl ?? "")) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            case .empty:
                                Color.gray.opacity(0.15)
                            case .failure:
                                Image(systemName: "car.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.gray.opacity(0.4))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.gray.opacity(0.15))
                            default:
                                Color.gray.opacity(0.15)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        VStack(alignment: .leading, spacing: 8) {
                            Text(service.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)

                            Text(detailer.companyName ?? detailer.displayName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)

                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                
                                Text("\(date.formatted(date: .abbreviated, time: .omitted)) · \(time)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()

                        Text("\(Int(adjustedPrice))€")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    if service.id != services.last?.id {
                        Divider().padding(.vertical, 8)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    // MARK: - Payment Section
    var paymentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 12) {
                ForEach(Payment.allCases, id: \.self) { method in
                    HStack(spacing: 16) {
                        Image(systemName: method.icon)
                            .font(.system(size: 20, weight: .medium))
                            .frame(width: 32, height: 32)
                            .foregroundColor(selectedPayment == method ? .white : .black)

                        Text(method.title)
                            .font(.system(size: 17, weight: .medium))

                        Spacer()

                        if selectedPayment == method {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(selectedPayment == method ? Color.black : Color.gray.opacity(0.1))
                    .foregroundColor(selectedPayment == method ? .white : .black)
                    .cornerRadius(16)
                    .onTapGesture { selectedPayment = method }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    // MARK: - Promo Code Section
    var promoCodeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.bookingPromoTitle())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                TextField(
                    R.string.localizable.bookingPromoPlaceholder(),
                    text: $promoCode
                )
                .textInputAutocapitalization(.characters)
                .disableAutocorrection(true)
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Button {
                    print("Apply promo: \(promoCode)")
                } label: {
                    Text(R.string.localizable.bookingPromoApply())
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .disabled(promoCode.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(promoCode.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    // MARK: - Notes Section
    var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.bookingNotes())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            // Fallback "Aucune note" si la clé bookingNoNotes n'existe pas encore
            Text(notes.isEmpty ? "Aucune note" : notes)
                .font(.system(size: 15))
                .foregroundColor(notes.isEmpty ? .gray : .black)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    // MARK: - Price Breakdown Section
    var priceBreakdownSection: some View {
        let canProceed = transportFeeError == nil
        
        return VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.bookingTotal())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 12) {
                // Services total
                HStack {
                    Text("Services")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(String(format: "%.2f €", totalServicesPrice))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                }
                
                // Transport fee
                if detailer.hasMobileService {
                    if let error = transportFeeError {
                        HStack {
                            Text(R.string.localizable.bookingTransportFee())
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                            Text(error)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                        }
                    } else if calculatedTransportFee > 0 {
                        HStack {
                            Text(R.string.localizable.bookingTransportFee())
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                            Text(String(format: "+%.2f €", calculatedTransportFee))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)
                        }
                    }
                }
                
                if detailer.hasMobileService && (calculatedTransportFee > 0 || transportFeeError != nil) {
                    Divider().padding(.vertical, 4)
                }
                
                // Total
                HStack {
                    Text(R.string.localizable.bookingTotal())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Text(String(format: "%.2f €", totalPrice))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            
            if selectedPayment == .cash {
                Divider().padding(.vertical, 8)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(R.string.localizable.bookingDeposit())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                        Text(R.string.localizable.bookingDepositRemainder())
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text(String(format: "%.2f €", amountToPay))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, cardInset)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    // MARK: - Terms Section
    var termsSection: some View {
        VStack(spacing: 4) {
            Text(R.string.localizable.bookingTerms1())
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            HStack(spacing: 4) {
                Button(R.string.localizable.bookingTermsConditions()) { }
                    .font(.system(size: 14, weight: .semibold))

                Text(R.string.localizable.bookingTermsAnd())
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Button(R.string.localizable.bookingTermsCancelPolicy()) { }
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Confirm Button
    var confirmButton: some View {
        let canProceed = transportFeeError == nil

        return Button {
            guard canProceed else { return }
            Task {
                await startPaymentFlow()
            }
        } label: {
            HStack(spacing: 12) {
                if selectedPayment == .cash {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(R.string.localizable.bookingPayNow())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Text(R.string.localizable.bookingDepositLabel(amountToPay))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                } else {
                    Text(R.string.localizable.bookingPayNow())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(String(format: "%.2f €", amountToPay))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.black.opacity(0.9)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            .opacity(canProceed ? 1.0 : 0.5)
        }
        .disabled(!canProceed)
    }
    
    // MARK: - Calculate Transport Fee
    @MainActor
    func calculateTransportFee() async {
        transportFeeError = nil
        
        guard detailer.hasMobileService else {
            calculatedTransportFee = 0
            calculatedTransportDistanceKm = nil
            return
        }
        
        guard !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            calculatedTransportFee = 0
            calculatedTransportDistanceKm = nil
            return
        }
        
        isCalculatingTransportFee = true
        defer { isCalculatingTransportFee = false }
        
        var transportFee: Double = 0
        var transportDistanceKm: Double? = nil
        
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            if let location = placemarks.first?.location {
                let customerAddressLat = location.coordinate.latitude
                let customerAddressLng = location.coordinate.longitude
                
                if detailer.lat != 0, detailer.lng != 0 {
                    let providerCoord = CLLocationCoordinate2D(latitude: detailer.lat, longitude: detailer.lng)
                    let customerCoord = CLLocationCoordinate2D(latitude: customerAddressLat, longitude: customerAddressLng)
                    
                    let distanceService = DistanceServiceImplementation()
                    transportDistanceKm = distanceService.calculateDistance(from: providerCoord, to: customerCoord)
                    
                    guard let distance = transportDistanceKm else {
                        calculatedTransportFee = 0
                        calculatedTransportDistanceKm = nil
                        return
                    }
                    
                    if distance > 25 {
                        transportFee = 20.0
                    } else if distance > 10 {
                        transportFee = 15.0
                    } else {
                        transportFee = 0.0
                    }
                }
            }
        } catch {
            print("⚠️ [MultiServiceBookingStep3View] Geocoding error:", error.localizedDescription)
        }
        
        calculatedTransportFee = transportFee
        calculatedTransportDistanceKm = transportDistanceKm
    }
    
    // MARK: - Start Payment Flow
    @MainActor
    func startPaymentFlow() async {
        isProcessingPayment = true
        defer { isProcessingPayment = false }
        
        // 1) Géocoder l'adresse et calculer la distance
        let (transportDistanceKm, customerAddressLat, customerAddressLng) = await geocodeAddressAndCalculateDistance()
        
        // 2) Créer les bookings pour chaque service
        guard let (createdBookings, firstClientSecret) = await createAllBookings(
            transportDistanceKm: transportDistanceKm,
            customerAddressLat: customerAddressLat,
            customerAddressLng: customerAddressLng
        ) else {
            return
        }
        
        // 3) Créer un PaymentIntent pour le montant total si nécessaire
        guard let finalClientSecret = await createPaymentIntentIfNeeded(
            bookingIds: createdBookings,
            existingClientSecret: firstClientSecret
        ) else {
            await cancelAllBookings(bookingIds: createdBookings)
            return
        }
        
        // 4) Traiter le paiement
        await processPaymentWithClientSecret(
            clientSecret: finalClientSecret,
            bookingIds: createdBookings
        )
    }
    
    // MARK: - Helper Functions
    
    @MainActor
    private func createAllBookings(
        transportDistanceKm: Double?,
        customerAddressLat: Double?,
        customerAddressLng: Double?
    ) async -> (bookings: [String], clientSecret: String?)? {
        var createdBookings: [String] = []
        var firstClientSecret: String?
        
        for service in services {
            let customerVehicleType = AppSession.shared.user?.customerProfile?.vehicleType
            let adjustedPrice = engine.vehiclePricingService.calculateAdjustedPrice(
                basePrice: service.price,
                vehicleType: customerVehicleType
            )
            
            let serviceTransportFee = services.count > 1 
                ? calculatedTransportFee / Double(services.count) 
                : calculatedTransportFee
            
            let bookingPayload = buildBookingPayload(
                service: service,
                adjustedPrice: adjustedPrice,
                serviceTransportFee: serviceTransportFee,
                transportDistanceKm: transportDistanceKm,
                customerAddressLat: customerAddressLat,
                customerAddressLng: customerAddressLng
            )
            
            let bookingRes = await engine.bookingService.createBooking(bookingPayload)
            
            guard case let .success(createResponse) = bookingRes else {
                if case let .failure(err) = bookingRes {
                    FirebaseManager.shared.recordError(
                        err,
                        userInfo: ["action": "create_multi_booking", "service_id": service.id]
                    )
                    showAlert("Erreur lors de la création de la réservation pour \(service.name): \(err.localizedDescription)")
                } else {
                    showAlert("Erreur lors de la création de la réservation pour \(service.name)")
                }
                await cancelAllBookings(bookingIds: createdBookings)
                return nil
            }
            
            createdBookings.append(createResponse.booking.id)
            
            if firstClientSecret == nil {
                firstClientSecret = createResponse.clientSecret
            }
            
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.bookingCreated,
                parameters: [
                    "booking_id": createResponse.booking.id,
                    "provider_id": detailer.id,
                    "service_id": service.id,
                    "price": adjustedPrice + serviceTransportFee,
                    "payment_method": selectedPayment == .cash ? "cash" : "card",
                    "is_multi_service": true
                ]
            )
        }
        
        return (createdBookings, firstClientSecret)
    }
    
    private func buildBookingPayload(
        service: Service,
        adjustedPrice: Double,
        serviceTransportFee: Double,
        transportDistanceKm: Double?,
        customerAddressLat: Double?,
        customerAddressLng: Double?
    ) -> [String: Any] {
        var payload: [String: Any] = [
            "provider_id": detailer.id,
            "service_id": service.id,
            "date": date.toISODateString(),
            "start_time": time,
            "end_time": time,
            "address": address,
            "payment_method": selectedPayment == .cash ? "cash" : "card",
            "transport_distance_km": transportDistanceKm ?? 0,
            "transport_fee": serviceTransportFee,
            "customer_address_lat": customerAddressLat ?? 0,
            "customer_address_lng": customerAddressLng ?? 0
        ]
        
        if selectedPayment == .cash {
            payload["deposit_amount"] = (adjustedPrice + serviceTransportFee) * 0.20
        }
        
        if !notes.trimmingCharacters(in: .whitespaces).isEmpty {
            payload["notes"] = notes.trimmingCharacters(in: .whitespaces)
        }
        
        return payload
    }
    
    @MainActor
    private func createPaymentIntentIfNeeded(
        bookingIds: [String],
        existingClientSecret: String?
    ) async -> String? {
        // ⚠️ IMPORTANT : Pour les paiements multi-services, on ne doit JAMAIS utiliser
        // le clientSecret des bookings individuels car ils sont créés pour le prix d'un seul service.
        // On doit toujours créer un nouveau PaymentIntent pour le montant total.
        if services.count > 1 {
            // Multi-services : créer un PaymentIntent pour le montant total
            let intentResponse = await engine.paymentService.createPaymentIntent(
                bookingId: bookingIds.first ?? "",
                amount: amountToPay,
                currency: "eur"
            )
            
            guard case let .success(intent) = intentResponse else {
                if case let .failure(err) = intentResponse {
                    showAlert("Erreur lors de la création du paiement: \(err.localizedDescription)")
                } else {
                    showAlert(R.string.localizable.errorPaymentFailedMessage())
                }
                return nil
            }
            
            return intent.clientSecret
        } else {
            // Single service : utiliser le clientSecret du booking si disponible
            if let clientSecret = existingClientSecret {
                return clientSecret
            }
            
            // Sinon, créer un nouveau PaymentIntent
            let intentResponse = await engine.paymentService.createPaymentIntent(
                bookingId: bookingIds.first ?? "",
                amount: amountToPay,
                currency: "eur"
            )
            
            guard case let .success(intent) = intentResponse else {
                if case let .failure(err) = intentResponse {
                    showAlert("Erreur lors de la création du paiement: \(err.localizedDescription)")
                } else {
                    showAlert(R.string.localizable.errorPaymentFailedMessage())
                }
                return nil
            }
            
            return intent.clientSecret
        }
    }
    
    @MainActor
    private func processPaymentWithClientSecret(
        clientSecret: String,
        bookingIds: [String]
    ) async {
        let paymentResult = await StripeManager.shared.confirmPayment(clientSecret)
        
        switch paymentResult {
        case .success:
            NotificationsManager.shared.notifyPaymentSuccess(
                transactionId: bookingIds.first ?? "",
                amount: amountToPay
            )
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.paymentCompleted,
                parameters: [
                    "booking_ids": bookingIds.joined(separator: ","),
                    "amount": amountToPay,
                    "currency": "eur",
                    "payment_method": selectedPayment == .cash ? "cash" : "card",
                    "services_count": services.count
                ]
            )
            
            // Créer les données de confirmation
            let serviceNames = services.map { $0.name }.joined(separator: ", ")
            confirmationData = BookingConfirmationData(
                bookingId: bookingIds.first,
                providerName: detailer.displayName,
                serviceName: services.count > 1 ? "\(services.count) services" : services.first?.name ?? "Service",
                price: amountToPay,
                currency: "eur",
                date: date.toISODateString(),
                startTime: time,
                endTime: time,
                address: address,
                paymentMethod: selectedPayment == .cash ? "cash" : "card",
                isMultiService: services.count > 1,
                servicesCount: services.count
            )
            
            goToConfirmation = true
            
        case .failure(let message):
            NotificationsManager.shared.notifyPaymentFailed(
                transactionId: bookingIds.first ?? ""
            )
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.paymentFailed,
                parameters: [
                    "booking_ids": bookingIds.joined(separator: ","),
                    "amount": amountToPay,
                    "currency": "eur",
                    "error_message": message
                ]
            )
            await cancelAllBookings(bookingIds: bookingIds)
            showAlert(message)
            
        case .canceled:
            NotificationsManager.shared.notifyPaymentFailed(
                transactionId: bookingIds.first ?? ""
            )
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.paymentFailed,
                parameters: [
                    "booking_ids": bookingIds.joined(separator: ","),
                    "amount": amountToPay,
                    "currency": "eur",
                    "error_message": "User canceled"
                ]
            )
            await cancelAllBookings(bookingIds: bookingIds)
            showAlert(R.string.localizable.shopPaymentCanceled())
        }
    }
    
    @MainActor
    private func cancelAllBookings(bookingIds: [String]) async {
        for bookingId in bookingIds {
            _ = await engine.bookingService.cancelBooking(id: bookingId)
        }
    }
    
    // MARK: - Helper Functions
    
    @MainActor
    private func geocodeAddressAndCalculateDistance() async -> (distance: Double?, lat: Double?, lng: Double?) {
        var transportDistanceKm: Double? = calculatedTransportDistanceKm
        var customerAddressLat: Double?
        var customerAddressLng: Double?
        
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            if let location = placemarks.first?.location {
                customerAddressLat = location.coordinate.latitude
                customerAddressLng = location.coordinate.longitude
                
                if transportDistanceKm == nil, detailer.lat != 0, detailer.lng != 0 {
                    let providerCoord = CLLocationCoordinate2D(latitude: detailer.lat, longitude: detailer.lng)
                    let customerCoord = CLLocationCoordinate2D(latitude: customerAddressLat!, longitude: customerAddressLng!)
                    let distanceService = DistanceServiceImplementation()
                    transportDistanceKm = distanceService.calculateDistance(from: providerCoord, to: customerCoord)
                }
            }
        } catch {
            print("⚠️ [MultiServiceBooking] Geocoding error:", error.localizedDescription)
        }
        
        return (transportDistanceKm, customerAddressLat, customerAddressLng)
    }
}
