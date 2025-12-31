import SwiftUI
import RswiftResources

struct BookingCardView: View {
    let booking: Booking
    let onManage: () -> Void      // 👉 modifier
    let onCancel: () -> Void      // 👉 annuler
    let onRepeat: () -> Void      // 👉 réserver à nouveau

    var body: some View {
        VStack(spacing: 0) {

            // --- Image + badge status ---
            ZStack(alignment: .topTrailing) {
                Group {
                    if let urlString = booking.imageURL,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    Color.gray.opacity(0.1)
                                    ProgressView()
                                }
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                ZStack {
                                    Color.gray.opacity(0.1)
                                    Image(systemName: "car.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                            @unknown default:
                                Color.gray.opacity(0.1)
                            }
                        }
                    } else {
                        ZStack {
                            Color.gray.opacity(0.1)
                            Image(systemName: "car.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                }
                .frame(height: 200)
                .clipped()

                VStack(alignment: .trailing, spacing: 8) {
                    BookingStatusBadge(status: booking.status, paymentStatus: booking.paymentStatus)
                    
                    if booking.paymentStatus != .paid && booking.paymentStatus != .pending {
                        PaymentStatusBadge(status: booking.paymentStatus)
                    }
                }
                .padding(12)
            }

            // --- Infos + actions ---
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(booking.displayProviderName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    Text(booking.displayServiceName)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        let timeForFormat = booking.displayStartTime == "—" ? "00:00" : booking.displayStartTime
                        Label(
                            DateFormatters.humanDate(from: booking.date, time: timeForFormat),
                            systemImage: "calendar"
                        )
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                        
                        Label(
                            String(format: "%.2f", booking.price) + " \(booking.currency.uppercased())",
                            systemImage: "eurosign.circle"
                        )
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                    }
                }

                Divider()
                
                // Actions
                if booking.status == .completed {
                    Button(action: onRepeat) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(R.string.localizable.bookingBookAgain())
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)

                } else {
                    HStack(spacing: 12) {
                        Button(action: onManage) {
                            HStack {
                                Image(systemName: "pencil")
                                Text(R.string.localizable.bookingManage())
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        Button(action: onCancel) {
                            HStack {
                                Image(systemName: "xmark")
                                Text(R.string.localizable.bookingCancel())
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}
