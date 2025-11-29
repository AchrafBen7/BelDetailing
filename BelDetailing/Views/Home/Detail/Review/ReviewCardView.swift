import SwiftUI
import RswiftResources

struct ReviewCardView: View {

    let review: Review

    @State private var isExpanded: Bool = false
    private let maxCollapsedLines: Int = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // HEADER : avatar + nom + rating + date
            HStack(alignment: .top, spacing: 12) {

                // Avatar avec initiales
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Text(initials(from: review.customerName))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(review.customerName)
                        .font(.system(size: 16, weight: .semibold))

                    starsRow(rating: review.rating)
                }

                Spacer()

                Text(formattedDate(from: review.createdAt))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            // COMMENTAIRE (si présent)
            if let comment = review.comment, !comment.isEmpty {
                VStack(alignment: .leading, spacing: 4) {

                    Text(comment)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .lineLimit(isExpanded ? nil : maxCollapsedLines)
                        .multilineTextAlignment(.leading)

                    // Bouton Read more / Read less UNIQUEMENT si texte assez long
                    if shouldShowToggle(for: comment) {
                        Button {
                            isExpanded.toggle()
                        } label: {
                            Text(
                                isExpanded
                                ? R.string.localizable.reviewsReadLess()
                                : R.string.localizable.reviewsReadMore()
                            )
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 2)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last  = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    private func formattedDate(from iso: String) -> String {
        let formatterIn = ISO8601DateFormatter()
        guard let date = formatterIn.date(from: iso) else { return "" }

        let out = DateFormatter()
        out.dateStyle = .medium
        out.timeStyle = .none
        return out.string(from: date)
    }

    private func starsRow(rating: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundColor(index <= rating ? .yellow : Color.gray.opacity(0.4))
                    .font(.system(size: 13))
            }
        }
    }

    /// Affiche le bouton Read more / Read less seulement si le texte est assez long
    private func shouldShowToggle(for comment: String) -> Bool {
        comment.count > 120
    }
}
