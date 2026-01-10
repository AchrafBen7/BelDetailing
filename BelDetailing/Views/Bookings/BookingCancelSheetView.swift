import SwiftUI
import RswiftResources
struct BookingCancelSheetView: View {
    let booking: Booking
    let engine: Engine
    
    @StateObject private var viewModel: BookingCancelSheetViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCancelConfirmation = false
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    
    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _viewModel = StateObject(wrappedValue: BookingCancelSheetViewModel(booking: booking, engine: engine))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // Title
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(R.string.localizable.bookingCancelConfirmTitle())
                        .font(.system(size: 22, weight: .bold))
                }
                .padding(.top, 20)
                
                Text(R.string.localizable.bookingCancelConfirmSubtitle())
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Refund Card
                refundCard
                
                Spacer(minLength: 20)
                
                // CONFIRM Button
                Button {
                    showCancelConfirmation = true
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(R.string.localizable.bookingCancelConfirmButton())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.canCancel ? Color.red : Color.gray)
                            .cornerRadius(30)
                    }
                }
                .disabled(!viewModel.canCancel || viewModel.isLoading)
                .padding(.horizontal, 20)
                
                // GO BACK Button
                Button {
                    dismiss()
                } label: {
                    Text(R.string.localizable.commonBack())
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 30)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .alert(R.string.localizable.bookingCancelConfirmTitle(), isPresented: $showCancelConfirmation) {
            Button(R.string.localizable.commonCancel(), role: .cancel) {}
            Button(R.string.localizable.bookingCancelConfirmButton(), role: .destructive) {
                Task {
                    let success = await viewModel.cancelBooking()
                    if success {
                        showSuccessAlert = true
                    } else {
                        showErrorAlert = true
                    }
                }
            }
        } message: {
            Text(refundMessage)
        }
        .errorAlert(
            isPresented: $showErrorAlert,
            title: R.string.localizable.errorGenericTitle(),
            message: viewModel.errorMessage ?? R.string.localizable.errorGenericMessage(),
            primaryAction: R.string.localizable.commonOk(),
            primaryActionHandler: nil
        )
        .errorAlert(
            isPresented: $showSuccessAlert,
            title: R.string.localizable.errorSuccessTitle(),
            message: refundSuccessMessage,
            primaryAction: R.string.localizable.commonOk(),
            primaryActionHandler: {
                dismiss()
            }
        )
    }
    
    private var refundCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(R.string.localizable.bookingPrice())
                    .font(.system(size: 16))
                Spacer()
                Text(String(format: "%.2f", viewModel.originalPrice) + " €")
                    .font(.system(size: 16, weight: .medium))
            }
            
            // Pour declined: pas de refund car preauthorized (rien n'a été prélevé)
            if booking.status == .declined {
                Divider()
                
                HStack {
                    Text(R.string.localizable.bookingRefund())
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Text("0 €")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                Text(R.string.localizable.bookingDeclinedNoCharge())
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            } else if viewModel.refundAmount > 0 {
                // Afficher les détails du remboursement
                let transportFee = booking.transportFeeAmount
                let isLessThan24hConfirmed = booking.hoursUntilBooking ?? 999 < 24.0 && booking.status == .confirmed
                
                if isLessThan24hConfirmed && transportFee > 0 {
                    // Cas spécial : < 24h ET confirmed → frais transport conservés
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(R.string.localizable.bookingServiceLabel())
                                .font(.system(size: 16))
                            Spacer()
                            Text(String(format: "%.2f", booking.servicePrice) + " €")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        HStack {
                            Text(R.string.localizable.bookingTransportFee())
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                            Spacer()
                            Text(String(format: "%.2f", transportFee) + " €")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        Text(R.string.localizable.bookingTransportFeeRetainedLabel())
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                        
                        Divider()
                        
                        HStack {
                            Text(R.string.localizable.bookingRefund())
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                            Text(String(format: "%.2f", viewModel.refundAmount) + " €")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        Text(R.string.localizable.bookingServiceRefundedTransportRetained())
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                } else {
                    // Remboursement standard
                    HStack {
                        Text(R.string.localizable.bookingCancellationFee())
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                        Spacer()
                        Text("-" + String(format: "%.2f", viewModel.originalPrice - viewModel.refundAmount) + " €")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text(R.string.localizable.bookingRefund())
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Text(String(format: "%.2f", viewModel.refundAmount) + " €")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    Text(refundRuleText)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            } else {
                Divider()
                
                HStack {
                    Text(R.string.localizable.bookingRefund())
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Text("0 €")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                Text(refundRuleText)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal, 20)
    }
    
    private var refundMessage: String {
        // Pour declined: pas de refund car preauthorized
        if booking.status == .declined {
            return R.string.localizable.bookingDeclinedCancellationMessage()
        }
        
        let transportFee = booking.transportFeeAmount
        let isLessThan24hConfirmed = (booking.hoursUntilBooking ?? 999) < 24.0 && booking.status == .confirmed
        
        if isLessThan24hConfirmed && transportFee > 0 {
            return R.string.localizable.bookingCancelledRefundTransport(
                String(format: "%.2f", viewModel.refundAmount),
                String(format: "%.2f", transportFee)
            )
        }
        
        if viewModel.refundPercentage == 100.0 {
            return R.string.localizable.bookingCancelledRefund100(String(format: "%.2f", viewModel.refundAmount))
        } else if viewModel.refundPercentage == 50.0 {
            return R.string.localizable.bookingCancelledRefund50(String(format: "%.2f", viewModel.refundAmount))
        } else {
            return R.string.localizable.bookingCancelledRefund0()
        }
    }
    
    private var refundSuccessMessage: String {
        // Pour declined: pas de refund
        if booking.status == .declined {
            return R.string.localizable.bookingCancelledNoRefundNeeded()
        }
        
        if viewModel.refundPercentage > 0 {
            return R.string.localizable.bookingCancelledRefundProcessing(String(format: "%.2f", viewModel.refundAmount))
        } else {
            return R.string.localizable.errorBookingCancelledMessage()
        }
    }
    
    private var refundRuleText: String {
        // Pour declined: message spécial
        if booking.status == .declined {
            return R.string.localizable.bookingCancellationRuleDeclined()
        }
        
        let transportFee = booking.transportFeeAmount
        let isLessThan24hConfirmed = (booking.hoursUntilBooking ?? 999) < 24.0 && booking.status == .confirmed
        
        if isLessThan24hConfirmed && transportFee > 0 {
            return R.string.localizable.bookingCancellationRuleLess24hTransport()
        }
        
        if viewModel.refundPercentage == 100.0 {
            return R.string.localizable.bookingCancellationRule48hPlus()
        } else if viewModel.refundPercentage == 50.0 {
            return R.string.localizable.bookingCancellationRule24h48h()
        } else {
            return R.string.localizable.bookingCancellationRuleLess24h()
        }
    }
}
