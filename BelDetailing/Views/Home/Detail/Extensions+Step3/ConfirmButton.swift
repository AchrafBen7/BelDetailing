import SwiftUI
import StripePaymentSheet
import RswiftResources

extension BookingStep3View {

    var confirmButton: some View {

        Button {
            Task {
                await startPaymentFlow()
            }
        } label: {
            Text("Betalen en bevestigen")
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.black)
                .cornerRadius(40)
        }

    }
}

extension Date {
    func toISODateString() -> String {
        let time = DateFormatter()
        time.dateFormat = "yyyy-MM-dd"
        return time.string(from: self)
    }
}

