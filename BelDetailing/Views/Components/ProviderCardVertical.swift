import SwiftUI
import RswiftResources

struct ProviderCardVertical: View {
  let provider: Detailer

  var body: some View {
    VStack(spacing: 0) {
      // === Image ===
      AsyncImage(url: provider.bannerURL) { phase in
        switch phase {
        case .empty:
          Color.gray.opacity(0.2).overlay(ProgressView())
        case .success(let image):
          image.resizable().scaledToFill()
        case .failure:
          Image(R.image.detailerBannerFallback.name).resizable().scaledToFill()
        @unknown default:
          EmptyView()
        }
      }
      .frame(height: 160)
      .clipped()
      .overlay(alignment: .topTrailing) {
        HStack(spacing: 6) {
          Image(systemName: "star.fill").font(.system(size: 13, weight: .bold))
          Text(String(format: "%.1f", provider.rating))
            .font(AppStyle.TextStyle.chipLabel.font)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.orange)
        .clipShape(Capsule())
        .padding(10)
      }

      // === Texte ===
      VStack(alignment: .leading, spacing: 6) {
        Text(provider.displayName)
          .font(AppStyle.TextStyle.sectionTitle.font)
          .foregroundColor(.black)

        Text(provider.serviceCategories.first?.localizedTitle ?? "")
          .font(AppStyle.TextStyle.description.font)
          .foregroundColor(.gray)

        HStack(spacing: 14) {
          Label(R.string.localizable.detailerDurationValue(provider.mockDurationText), systemImage: "clock")
          Label(R.string.localizable.detailerDistanceKmValue(provider.mockDistanceKmText), systemImage: "mappin.and.ellipse")
          Spacer()
          Text("\(provider.reviewCount) \(R.string.localizable.providerReviewsCount())")
        }
        .font(AppStyle.TextStyle.chipLabel.font)
        .foregroundColor(.gray)
      }
      .padding()
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
  }
}
