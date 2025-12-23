import SwiftUI
import RswiftResources

struct ProviderServiceCardView: View {

    let service: Service
    let onEdit: () -> Void
    let onDelete: () -> Void

    private let buttonHeight: CGFloat = 48
    private let corner: CGFloat = 14

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // HEADER: Titre + Statut + Prix
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(service.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(R.color.primaryText))
                            .lineLimit(2)

                        // Statut dans une capsule neutre avec icône
                        HStack(spacing: 6) {
                            Image(systemName: service.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(service.isAvailable ? .green : .red)
                            Text(service.isAvailable ? "Disponible" : "Indisponible")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(service.isAvailable ? .green : .red)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.10))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    // Prix principal bien lisible
                    Text("€\(Int(service.price))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(R.color.primaryText))
                }
                .padding(.top, 14)
                .padding(.bottom, 12)

                Divider().background(Color.black.opacity(0.06))

                // MIDDLE: Description + Meta (durée / réservations)
                VStack(alignment: .leading, spacing: 12) {
                    if let desc = service.description, !desc.isEmpty {
                        Text(desc)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .lineLimit(3)
                    }

                    HStack(spacing: 14) {
                        metaItem(icon: "clock", title: service.formattedDuration)
                        Rectangle().fill(Color.black.opacity(0.08)).frame(width: 1, height: 16)
                        metaItem(icon: "calendar", title: "\(service.reservationCount ?? 0) réservations")
                        Spacer(minLength: 0)
                    }
                }
                .padding(.vertical, 12)

                // FOOTER: Actions (primary + secondary)
                HStack(spacing: 10) {
                    // EDIT — bouton principal noir, contenu centré
                    Button(action: onEdit) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.pencil")
                            Text(R.string.localizable.dashboardEdit())
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight) // hauteur fixe
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                    }

                    // DELETE — même hauteur, style secondaire
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                            .background(Color.black.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                    }
                    .frame(width: 56) // largeur compacte mais même hauteur
                }
                .padding(.bottom, 14)
            }
            .padding(.horizontal, 16) // padding commun pour aligner tous les blocs
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Subviews
    private func metaItem(icon: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .frame(alignment: .leading)
    }
}
