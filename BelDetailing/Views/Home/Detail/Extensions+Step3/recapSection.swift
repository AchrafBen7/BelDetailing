//
//  recapSection.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

extension BookingStep3View {

    var recapSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            // TITLE
            Text(R.string.localizable.bookingSummary())
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: 16) {

                HStack(alignment: .top, spacing: 16) {

                    // === SERVICE IMAGE ===
                    AsyncImage(url: serviceImageURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()

                        case .empty:
                            Color.gray.opacity(0.15)

                        case .failure:
                            Image(systemName: "car.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.gray.opacity(0.4))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.15))

                        default:
                            Color.gray.opacity(0.15)
                        }
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // === TEXT BLOCK ===
                    VStack(alignment: .leading, spacing: 6) {

                        Text(service.name)
                            .font(.system(size: 19, weight: .semibold))

                        Text(detailer.companyName ?? detailer.displayName)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)

                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))

                            Text("\(date.formatted(date: .abbreviated, time: .omitted)) · \(time)")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    // PRICE
                    Text("\(Int(service.price))€")
                        .font(.system(size: 20, weight: .bold))
                }

                Divider()

                HStack {
                    Text(R.string.localizable.bookingPriceLabel())
                    Spacer()
                    Text("\(Int(service.price))€")
                        .font(.system(size: 16, weight: .semibold))
                }

            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
        }
    }

    /// SAFE image URL (évite tous les crashs + optionals)
    private var serviceImageURL: URL? {
        guard let urlString = service.imageUrl,
              !urlString.trimmingCharacters(in: .whitespaces).isEmpty,
              let url = URL(string: urlString)
        else {
            return nil
        }
        return url
    }
}
