//
//  OfferDetailView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 18/12/2025.
//
import SwiftUI
import RswiftResources

struct OfferDetailView: View {

    let engine: Engine
    let offerId: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility

    @State private var offer: Offer?
    @State private var isLoading = true

    var body: some View {
        ZStack(alignment: .bottom) {

            // Fond noir global
            Color.black.ignoresSafeArea()

            if let offer {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        header(offer)
                        mainCard(offer)
                        statsRow(offer)
                        descriptionSection(offer)
                        servicesSection
                        Spacer(minLength: 120) // espace pour le CTA bas
                    }
                    .background(Color(R.color.mainBackground.name))
                }

                bottomCTA // collé en bas, respecte la safe area
            } else if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(R.string.localizable.genericError())
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .task { await loadOffer() }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Cacher la tab bar uniquement sur cet écran
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            // Ré-afficher la tab bar quand on quitte
            tabBarVisibility.isHidden = false
        }
    }

    private func loadOffer() async {
        let res = await engine.offerService.getOfferDetail(id: offerId)
        if case let .success(item) = res {
            offer = item
        }
        isLoading = false
    }
}

// MARK: - Sections
private extension OfferDetailView {

    // 1) Header noir
    func header(_ offer: Offer) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text("Détails de l'offre")
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Button { /* partager plus tard */ } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .foregroundColor(.white)

            HStack(spacing: 14) {
                Image(systemName: "building.2")
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.companyName ?? "Entreprise")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))

                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text("4.8")
                        Text("(124 avis)")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                }

                Spacer()

                Text("Vérifié")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(Color.black)
    }

    // 2) Card principale (titre / type / budget / deadline)
    func mainCard(_ offer: Offer) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top) {
                Text(offer.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(R.color.primaryText))

                Spacer()

                OfferTypeBadge(type: offer.type)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Budget")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    Text(offer.formattedBudget)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Date limite")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    Text("15 Janvier 2025") // Placeholder (pas dans le modèle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        .padding(.horizontal, 20)
    }

    // 3) Stats (localisation / véhicules / candidats)
    func statsRow(_ offer: Offer) -> some View {
        HStack(spacing: 12) {
            statItem("Localisation", offer.city, "mappin.and.ellipse")
            statItem("Véhicules", "\(offer.vehicleCount)", "car.fill")
            statItem("Candidats", "\(offer.applicationsCount ?? 0)", "person.2.fill")
        }
        .padding(.horizontal, 20)
    }

    func statItem(_ title: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.black)

            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    // 4) Description
    func descriptionSection(_ offer: Offer) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(R.color.primaryText))

            Text(offer.description.isEmpty
                 ? R.string.localizable.noDescription()
                 : offer.description)
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
    }

    // 5) Services demandés (tags)
    var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services demandés")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(R.color.primaryText))

            // Simple grille adaptative pour imiter un wrap
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                serviceChip("Lavage extérieur")
                serviceChip("Nettoyage intérieur")
                serviceChip("Aspiration")
                serviceChip("Traitement plastiques")
                serviceChip("Nettoyage vitres")
            }
        }
        .padding(.horizontal, 20)
    }

    func serviceChip(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.black.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }

    // 6) CTA bas (respecte la safe area)
    var bottomCTA: some View {
        VStack(spacing: 12) {
            Divider()
                .background(Color.black.opacity(0.1))

            HStack(spacing: 12) {

                Button {
                    // message / chat plus tard
                } label: {
                    Image(systemName: "message")
                        .foregroundColor(.black)
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.12), radius: 6, y: 4)
                }

                Button {
                    // postuler
                    if let offer {
                        Task {
                            _ = await engine.applicationService.apply(toOffer: offer.id, data: [:])
                        }
                    }
                } label: {
                    Text("Postuler maintenant")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.black)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color(R.color.mainBackground.name).ignoresSafeArea(edges: .bottom))
        }
    }
}

// MARK: - Helpers
private extension Offer {
    var formattedBudget: String {
        if priceMin <= 0, priceMax > 0 {
            return "€\(Int(priceMax))"
        } else if priceMin > 0, priceMax > 0, priceMin != priceMax {
            return "€\(Int(priceMin)) – €\(Int(priceMax))"
        } else {
            return "€\(Int(priceMin))"
        }
    }
}
