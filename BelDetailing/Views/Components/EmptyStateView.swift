import SwiftUI
import RswiftResources

struct EmptyStateView: View {
  let title: String
  let message: String
  var systemIcon: String = "magnifyingglass.circle"

  /// Actions optionnelles
  var onRetry: (() -> Void)? = nil
  var onClear: (() -> Void)? = nil

  var body: some View {
    ZStack(alignment: .topTrailing) {
      // --- Carte blanche ---
      VStack(spacing: 20) {
        // Titre
        title.textView(style: AppStyle.TextStyle.sectionTitle, multilineAlignment: .center)
          .foregroundColor(.black)
          .padding(.horizontal, 12)

        // Message
        message.textView(style: AppStyle.TextStyle.description,
                         overrideColor: .secondary,
                         multilineAlignment: .center)
          .padding(.horizontal, 20)
          .lineSpacing(2)

        // Bouton Réessayer (si fourni)
        if let onRetry {
          Button(action: onRetry) {
            Text(R.string.localizable.commonRetry())
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(.white)
              .padding(.horizontal, 24)
              .padding(.vertical, 10)
              .background(Color.black)
              .clipShape(Capsule())
              .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
          }
          .buttonStyle(.plain)
          .padding(.top, 6)
        }
      }
      .padding(.vertical, 36)
      .padding(.horizontal, 32)
      .background(Color.white)
      .cornerRadius(24)
      .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
      .frame(maxWidth: 320)
      .multilineTextAlignment(.center)

      // Bouton ✕ (reset filtres)
      if let onClear {
        Button(action: onClear) {
          Image(systemName: "xmark")
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 32, height: 32)
            .background(Color.white.opacity(0.95))
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .padding(10)
        .accessibilityLabel(Text(R.string.localizable.filterResetA11y())) // ajoute cette clé si besoin
      }
    }
    .padding()
  }
}
