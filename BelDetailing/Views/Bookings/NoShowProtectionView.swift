//
//  NoShowProtectionView.swift
//  BelDetailing
//
//  Vue pour gérer le no-show (client absent)
//

import SwiftUI
import RswiftResources
import CoreLocation
import Combine
struct NoShowProtectionView: View {
    let booking: Booking
    let engine: Engine
    
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var viewModel: NoShowProtectionViewModel
    
    @State private var showNoShowConfirmation = false
    @State private var countdownSeconds: Int = 600 // 10 minutes = 600 secondes
    @State private var timer: Timer?
    @State private var isCountdownActive = false
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: NoShowProtectionViewModel(booking: booking, engine: engine))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                
                Text("Protection No-Show")
                    .font(.system(size: 22, weight: .bold))
                
                Text("Vous êtes arrivé sur place ?")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            // Status GPS
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                VStack(spacing: 12) {
                    Image(systemName: "location.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                    
                    Text("Localisation désactivée")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Activez la localisation dans les réglages pour utiliser cette fonctionnalité.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button("Ouvrir les réglages") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .clipShape(Capsule())
                }
                .padding(20)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else if let _ = locationManager.currentLocation,
                      let bookingLat = booking.addressLat,
                      let bookingLng = booking.addressLng {
                // Vérification de proximité
                let isNear = locationManager.isNearBookingAddress(
                    bookingAddress: booking.address,
                    bookingLat: bookingLat,
                    bookingLng: bookingLng
                )
                
                let distance = locationManager.distanceToBookingAddress(
                    bookingLat: bookingLat,
                    bookingLng: bookingLng
                ) ?? 0
                
                VStack(spacing: 16) {
                    if isNear {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            
                            Text("Vous êtes sur place")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "location.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Distance: \(Int(distance)) m")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Approchez-vous de l'adresse du client")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Localisation en cours...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(20)
            }
            
            // Bouton "Client absent"
            if locationManager.currentLocation != nil {
                VStack(spacing: 12) {
                    Button {
                        showNoShowConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.xmark")
                            Text("Client absent")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    if isCountdownActive {
                        VStack(spacing: 8) {
                            Text("Attente en cours...")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text(formatCountdown(countdownSeconds))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.orange)
                            
                            Text("Le paiement partiel sera automatiquement validé")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(16)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            Spacer()
        }
        .padding(20)
        .onAppear {
            locationManager.requestAuthorization()
            locationManager.startLocationUpdates()
        }
        .onDisappear {
            locationManager.stopLocationUpdates()
            timer?.invalidate()
        }
        .alert("Client absent", isPresented: $showNoShowConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Confirmer") {
                startNoShowCountdown()
            }
        } message: {
            Text("Un délai de 10 minutes sera lancé. Si le client n'arrive pas, vous recevrez un paiement partiel automatiquement.")
        }
        .alert("No-Show confirmé", isPresented: Binding(
            get: { viewModel.noShowConfirmed },
            set: { _ in }
        )) {
            Button("OK") {
                // Retour à la vue précédente
            }
        } message: {
            Text("Le paiement partiel a été validé. Vous recevrez \(String(format: "%.2f", viewModel.partialPaymentAmount ?? 0))€.")
        }
    }
    
    private func startNoShowCountdown() {
        isCountdownActive = true
        countdownSeconds = 600 // 10 minutes
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] timer in
            if countdownSeconds > 0 {
                countdownSeconds -= 1
            } else {
                timer.invalidate()
                Task {
                    await viewModel.confirmNoShow()
                }
            }
        }
    }
    
    private func formatCountdown(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - ViewModel

@MainActor
final class NoShowProtectionViewModel: ObservableObject {
    @Published var noShowConfirmed = false
    @Published var partialPaymentAmount: Double?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let booking: Booking
    let engine: Engine
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
    }
    
    func confirmNoShow() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await engine.bookingService.reportNoShow(bookingId: booking.id)
        
        switch result {
        case .success(let response):
            noShowConfirmed = true
            partialPaymentAmount = response.partialPaymentAmount
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

