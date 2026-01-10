import SwiftUI
import StripePaymentSheet
import RswiftResources

extension BookingStep3View {

    var confirmButton: some View {
        // ✅ Utiliser le même calcul que le backend : service.price + transportFee (sans ajustement véhicule)
        let servicePrice = service.price
        let transportFee = calculatedTransportFee
        let totalPrice = servicePrice + transportFee
        
        // Calculer le montant à payer selon la méthode de paiement
        let amountToPay = selectedPayment == .cash ? totalPrice * 0.20 : totalPrice
        
        // Vérifier si on peut procéder (pas d'erreur de transport)
        let canProceed = transportFeeError == nil

        return Button {
            guard canProceed else { return } // Bloquer si erreur de transport
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
            .opacity(canProceed ? 1.0 : 0.5) // Désactiver visuellement si erreur
        }
        .disabled(!canProceed) // Désactiver le bouton si erreur
    }
}

extension Date {
    func toISODateString() -> String {
        let time = DateFormatter()
        time.dateFormat = "yyyy-MM-dd"
        return time.string(from: self)
    }
}

