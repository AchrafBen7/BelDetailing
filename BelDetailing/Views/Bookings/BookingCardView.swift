import SwiftUI
import RswiftResources

struct BookingCardView: View {
  let booking: Booking

  // Callbacks
  var onViewDetails: () -> Void = {}
  var onEdit: () -> Void = {}
  var onContact: () -> Void = {}
  var onCancel: () -> Void = {}

  @State private var isMenuPresented = false

  var body: some View {
    ZStack {
      // --- La carte complète ---
      cardContent

      // --- Menu overlay ---
      if isMenuPresented {
        Color.black.opacity(0.001) // clic pour fermer (zone = la carte)
          .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
              isMenuPresented = false
            }
          }

        VStack {
          Spacer(minLength: 0)
          HStack {
            Spacer()
            BookingActionsMenu(
              onViewDetails: closeThen(onViewDetails),
              onEdit: closeThen(onEdit),
              onContact: closeThen(onContact),
              onCancel: closeThen(onCancel)
            )
            .padding(.trailing, 24)
            .padding(.bottom, 40)
          }
        }
      }
    }
  }

  // MARK: - Contenu de la carte

  private var cardContent: some View {
    VStack(spacing: 0) {

      // ===== Image + badge =====
      ZStack(alignment: .topTrailing) {
        AsyncImage(url: URL(string: booking.imageURL ?? "")) { phase in
          switch phase {
          case .empty:
            Color.gray.opacity(0.2).overlay(ProgressView())
          case .success(let image):
            image
              .resizable()
              .scaledToFill()
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

      // ===== Infos + boutons =====
      VStack(alignment: .leading, spacing: 8) {
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
          .font(.system(size: 14))
          .foregroundColor(.gray)

          Label(R.string.localizable.bookingGuestsCount(2), systemImage: "person.2")
            .font(.system(size: 14))
            .foregroundColor(.gray)
        }

        HStack(spacing: 8) {
          Button(action: onViewDetails) {
            Text(R.string.localizable.bookingManage())
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(.black)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 10)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.black.opacity(0.3), lineWidth: 1)
              )
          }

          Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
              isMenuPresented.toggle()
            }
          } label: {
            Image(systemName: "ellipsis")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.black)
              .frame(width: 40, height: 40)
              .background(Color.white)
              .clipShape(Circle())
              .overlay(
                Circle()
                  .stroke(Color.black.opacity(0.15), lineWidth: 1)
              )
          }
          .buttonStyle(.plain)
        }
        .padding(.top, 4)
      }
      .padding(16)
    }
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
  }

  // MARK: - Helper

  private func closeThen(_ action: @escaping () -> Void) -> () -> Void {
    {
      withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
        isMenuPresented = false
      }
      action()
    }
  }
}

// MARK: - Petit menu popup

private struct BookingActionsMenu: View {
  var onViewDetails: () -> Void
  var onEdit: () -> Void
  var onContact: () -> Void
  var onCancel: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Group {
        ActionRow(
          title: R.string.localizable.bookingActionViewDetails(),
          systemImage: "doc.text",
          isDestructive: false,
          action: onViewDetails
        )
        ActionRow(
          title: R.string.localizable.bookingActionEdit(),
          systemImage: "calendar",
          isDestructive: false,
          action: onEdit
        )
        ActionRow(
          title: R.string.localizable.bookingActionContact(),
          systemImage: "bubble.left",
          isDestructive: false,
          action: onContact
        )
      }

      Divider().padding(.leading, 44)

      ActionRow(
        title: R.string.localizable.bookingActionCancel(),
        systemImage: "xmark",
        isDestructive: true,
        action: onCancel
      )
    }
    .padding(.vertical, 8)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 18))
    .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
  }

  private struct ActionRow: View {
    let title: String
    let systemImage: String
    let isDestructive: Bool
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack(spacing: 12) {
          Image(systemName: systemImage)
            .font(.system(size: 18))
            .foregroundColor(isDestructive ? .red : .black)

          Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(isDestructive ? .red : .black)

          Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
      }
      .buttonStyle(.plain)
    }
  }
}
