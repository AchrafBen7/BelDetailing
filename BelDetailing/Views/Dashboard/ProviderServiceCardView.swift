import SwiftUI
import RswiftResources

struct ProviderServiceCardView: View {

    let service: Service
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // MARK: - Title + Status Dot
            HStack(alignment: .center) {

                Text(service.name)
                    .textView(style: .sectionTitle)

                Spacer()

                Circle()
                    .fill(service.isAvailable ? Color.green : Color.red.opacity(0.6))
                    .frame(width: 10, height: 10)
            }

            // MARK: - Description
            if let desc = service.description, !desc.isEmpty {
                Text(desc)
                    .textView(style: .description, color: Color(R.color.secondaryText))
            }

            // MARK: - Price + Duration + Reservations
            HStack(spacing: 28) {

                // PRICE
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "%.0f€", service.price))
                        .font(.system(size: 28, weight: .semibold))   // EXACT comme la photo
                        .foregroundColor(Color(R.color.primaryText))

                    Text(service.formattedDuration)
                        .textView(style: .caption)
                        .foregroundColor(Color.gray)
                }

                Divider().frame(height: 40)

                // RESERVATION COUNT
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(service.reservationCount ?? 0)")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(R.color.primaryText))

                    Text(R.string.localizable.dashboardReservations())
                        .textView(style: .caption)
                        .foregroundColor(Color.gray)

                }
            }

            // MARK: - Buttons
            HStack(spacing: 12) {

                // EDIT BUTTON
                Button(action: onEdit) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 16, weight: .semibold))

                        Text(R.string.localizable.dashboardEdit())
                            .font(.system(size: 16, weight: .semibold))   // ⬅️ plus petit
                            .baselineOffset(0)                            // ⬅️ parfait alignement
                    }
                    .foregroundColor(Color(R.color.primaryText))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)      // ⬅️ un peu plus compact que 10
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                    )
                }

                // DELETE BUTTON
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 44, height: 44)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }

        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}
