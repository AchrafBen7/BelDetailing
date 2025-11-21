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
                AsyncImage(url: URL(string: booking.imageURL ?? "")) { phase in
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

                Text(booking.providerName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Text(booking.serviceName)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)

                HStack(spacing: 12) {
                    Label(
                        DateFormatters.humanDate(from: booking.date, time: booking.startTime),
                        systemImage: "calendar"
                    )
                    .foregroundColor(.gray)
                    .font(.system(size: 14))

                    Label(R.string.localizable.bookingGuestsCount(2), systemImage: "person.2")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }

                // --- Actions ---
                if booking.status == .completed {
                    // 👉 RÉSERVER À NOUVEAU (un seul long bouton)
                    Button(action: onRepeat) {
                        Text(R.string.localizable.bookingBookAgain()) // ajoute cette key dans Localizable
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
                    // 👉 MODIFIER + ANNULER (comme avant)
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
