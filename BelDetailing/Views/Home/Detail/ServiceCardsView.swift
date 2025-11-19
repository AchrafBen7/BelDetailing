import SwiftUI
import RswiftResources

struct ServiceCardView: View {
    let service: Service
    let onBook: () -> Void
    init(service: Service, onBook: @escaping () -> Void = {}) {
        self.service = service
        self.onBook = onBook
    }
    var body: some View {
        VStack(spacing: 0) {
            // --- IMAGE SERVICE ---
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: service.serviceImageURL) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .empty:
                        Color.gray.opacity(0.15)
                    case .failure:
                        Image(systemName: "car.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.2))
                    @unknown default:
                        Color.gray.opacity(0.15)
                    }
                }
                .frame(height: 200)
                .clipped()
                // PRICE BADGE
                Text("€\(Int(service.price))")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    .padding(14)
            }
            // --- CONTENT ---
            VStack(alignment: .leading, spacing: 16) {
                // TITLE + DURATION
                HStack {
                    Text(service.name)
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                        Text(service.formattedDuration)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.gray)
                }
                
                // DESCRIPTION
                if let desc = service.description {
                    Text(desc)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                // ✅ INCLUDED BUBBLE – DESIGN COMME MAQUETTE 2
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                        Text(R.string.localizable.detailIncluded())
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    // 2 colonnes, bullets bien alignés
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), alignment: .leading),
                            GridItem(.flexible(), alignment: .leading)
                        ],
                        alignment: .leading,
                        spacing: 8
                    ) {
                        includedRow(R.string.localizable.serviceIncludedWash())
                        includedRow(R.string.localizable.serviceIncludedDecontamination())
                        includedRow(R.string.localizable.serviceIncludedPolish2Steps())
                        includedRow(R.string.localizable.serviceIncludedWaxProtection())
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                
                // BUTTON
                Button {
                    onBook()
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(R.string.localizable.detailBookService())
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(28)
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.12), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.07), radius: 10, y: 5)
        .padding(.horizontal, 8)
    }
    // MARK: - PRIVATE HELPERS
    /// Une ligne "• Texte" bien propre, qui ne coupe pas bizarrement
    private func includedRow(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(.black)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
