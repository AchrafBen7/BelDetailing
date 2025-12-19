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
                                Color.gray.opacity(0.2).overlay(ProgressView())
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Color.gray.opacity(0.2)
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                    } else {
                        Color.gray.opacity(0.15)
                    }
                }
                .frame(height: 180)
                .clipped()

                Text(booking.status.localizedTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(booking.status.badgeBackground)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(10)
            }

            // --- Infos + actions ---
            VStack(alignment: .leading, spacing: 10) {

                Text(booking.displayProviderName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Text(booking.displayServiceName)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)

                HStack(spacing: 12) {
                    let timeForFormat = booking.displayStartTime == "—" ? "00:00" : booking.displayStartTime
                    Label(
                        DateFormatters.humanDate(from: booking.date, time: timeForFormat),
                        systemImage: "calendar"
                    )
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                }

                if booking.status == .completed {
                    Button(action: onRepeat) {
                        Text(R.string.localizable.bookingBookAgain())
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)

                } else {
                    HStack(spacing: 10) {

                        Button(action: onManage) {
                            Text(R.string.localizable.bookingManage())
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)

                        Button(action: onCancel) {
                            Text(R.string.localizable.bookingCancel())
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                )
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
    }
}
