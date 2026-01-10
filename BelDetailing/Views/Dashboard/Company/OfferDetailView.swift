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
    @State private var errorMessage: String?
    @State private var myApplication: Application?
    @State private var allApplications: [Application] = [] // Pour les companies
    @State private var isApplying = false
    @State private var isWithdrawing = false
    @State private var showSuccessMessage = false
    @State private var showWithdrawConfirmation = false

    // Helper pour savoir si l'utilisateur est une company
    private var isCompany: Bool {
        engine.userService.fullUser?.role == .company
    }

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
                        
                        // Banner de statut de candidature (pour les providers) - déplacé ici pour meilleure visibilité
                        if !isCompany, let application = myApplication {
                            applicationStatusBanner(application)
                        }
                        
                        servicesSection
                        
                        // Section des candidatures pour les companies
                        if isCompany && !allApplications.isEmpty {
                            applicationsSection
                        }
                        
                        Spacer(minLength: 120) // espace pour le CTA bas
                    }
                    .background(Color(R.color.mainBackground.name))
                }

                bottomCTA // collé en bas, respecte la safe area
            } else if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text(errorMessage ?? R.string.localizable.genericError())
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Button {
                        Task {
                            await loadOffer()
                        }
                    } label: {
                        Text("Réessayer")
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .task { 
            await loadOffer()
            // Ne vérifier l'application que si c'est une company
            // Pour les providers, on gère via l'erreur 400 lors de la candidature
            if isCompany {
                await checkMyApplication()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Cacher la tab bar uniquement sur cet écran
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            // Ré-afficher la tab bar quand on quitte
            tabBarVisibility.isHidden = false
        }
        .alert("Candidature envoyée", isPresented: $showSuccessMessage) {
            Button("OK") {
                // Recharger l'application après succès
                Task {
                    await checkMyApplication()
                }
            }
        } message: {
            Text("Votre candidature a été envoyée avec succès.")
        }
        .alert("Retirer la candidature", isPresented: $showWithdrawConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Retirer", role: .destructive) {
                Task {
                    await withdrawApplication()
                }
            }
        } message: {
            Text("Êtes-vous sûr de vouloir retirer votre candidature ?")
        }
    }

    private func loadOffer() async {
        isLoading = true
        errorMessage = nil
        
        print("🔄 [OfferDetailView] Loading offer with id: \(offerId)")
        let res = await engine.offerService.getOfferDetail(id: offerId)
        
        switch res {
        case .success(let item):
            print("✅ [OfferDetailView] Successfully loaded offer")
            offer = item
        case .failure(let error):
            print("❌ [OfferDetailView] Error loading offer: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func checkMyApplication() async {
        // Vérifier si l'utilisateur a déjà postulé
        guard let currentUser = engine.userService.fullUser else {
            print("⚠️ [OfferDetailView] No current user, skipping application check")
            return
        }
        
        // Endpoint réservé aux companies
        guard currentUser.role == .company else {
            print("ℹ️ [OfferDetailView] User is not a company, skipping application check (will handle via 400 error on apply)")
            return
        }
        
        let currentUserId = currentUser.id
        
        print("🔄 [OfferDetailView] Checking if user has already applied...")
        let res = await engine.applicationService.getApplications(forOffer: offerId)
        
        switch res {
        case .success(let applications):
            // Company peut voir toutes les applications
            allApplications = applications
            print("✅ [OfferDetailView] Loaded \(applications.count) applications for company")
        case .failure(let error):
            if case .serverError(let statusCode) = error, statusCode == 403 {
                print("ℹ️ [OfferDetailView] 403 error - user is not a company, this is expected for providers")
            } else {
                print("❌ [OfferDetailView] Error checking applications: \(error)")
            }
        }
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
    
    // 6) Section des candidatures (pour les companies)
    var applicationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Candidatures (\(allApplications.count))")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(R.color.primaryText))
            
            if allApplications.isEmpty {
                Text("Aucune candidature pour le moment")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(allApplications) { application in
                        applicationCard(application)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    func applicationCard(_ application: Application) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Avatar ou icône
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(application.providerName.prefix(1)).uppercased())
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.orange)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.providerName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(applicationStatusText(application.status))
                        .font(.system(size: 14))
                        .foregroundColor(applicationStatusColor(application.status))
                }
                
                Spacer()
                
                // Badge de statut
                Text(application.status.rawValue.capitalized)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(applicationStatusColor(application.status))
                    .clipShape(Capsule())
            }
            
            if let message = application.message, !message.isEmpty {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            
            // Date de candidature
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Text(formatDate(application.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
    
    func applicationStatusText(_ status: ApplicationStatus) -> String {
        switch status {
        case .submitted:
            return "Candidature envoyée"
        case .underReview:
            return "En cours d'examen"
        case .accepted:
            return "Candidature acceptée"
        case .refused:
            return "Candidature refusée"
        case .withdrawn:
            return "Candidature retirée"
        }
    }
    
    func applicationStatusColor(_ status: ApplicationStatus) -> Color {
        switch status {
        case .submitted, .underReview:
            return .orange
        case .accepted:
            return .green
        case .refused, .withdrawn:
            return .red
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            displayFormatter.locale = Locale(identifier: "fr_FR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }

    // 6) CTA bas (respecte la safe area)
    var bottomCTA: some View {
        VStack(spacing: 12) {
            Divider()
                .background(Color.black.opacity(0.1))

            HStack(spacing: 12) {
                // Bouton message uniquement pour les providers
                if !isCompany {
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
                }

                if isCompany {
                    // Company: pas de CTA "Postuler"
                    Spacer(minLength: 0)
                } else if myApplication != nil {
                    // Provider: déjà postulé -> bouton désactivé "Déjà postulé"
                    Button {
                        // Désactivé - ne rien faire
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Déjà postulé")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(16)
                    .disabled(true)
                    .allowsHitTesting(false) // Empêche complètement l'interaction
                } else {
                    // Provider: bouton actif pour postuler
                    Button {
                        Task {
                            await applyToOffer()
                        }
                    } label: {
                        if isApplying {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity, minHeight: 56)
                        } else {
                            Text("Postuler maintenant")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 56)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(isApplying ? Color.gray : Color.black)
                    .cornerRadius(16)
                    .disabled(isApplying)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color(R.color.mainBackground.name).ignoresSafeArea(edges: .bottom))
        }
    }
    
    private var applicationButtonText: String {
        guard let application = myApplication else { return "Postuler maintenant" }
        switch application.status {
        case .submitted:
            return "Candidature envoyée"
        case .underReview:
            return "En cours d'examen"
        case .accepted:
            return "Candidature acceptée"
        case .refused:
            return "Candidature refusée"
        case .withdrawn:
            return "Candidature retirée"
        }
    }
    
    private var applicationButtonColor: Color {
        guard let application = myApplication else { return .black }
        switch application.status {
        case .submitted, .underReview:
            return .orange
        case .accepted:
            return .green
        case .refused, .withdrawn:
            return .gray
        }
    }
    
    private func applicationStatusBanner(_ application: Application) -> some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon(for: application.status))
                .font(.system(size: 18))
                .foregroundColor(statusColor(for: application.status))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(statusTitle(for: application.status))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(statusMessage(for: application.status))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white) // Background blanc opaque pour masquer le texte derrière
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2) // Ombre légère pour la profondeur
        .padding(.horizontal, 20)
    }
    
    private func statusIcon(for status: ApplicationStatus) -> String {
        switch status {
        case .submitted:
            return "paperplane.fill"
        case .underReview:
            return "eye.fill"
        case .accepted:
            return "checkmark.circle.fill"
        case .refused:
            return "xmark.circle.fill"
        case .withdrawn:
            return "arrow.uturn.backward.circle.fill"
        }
    }
    
    private func statusColor(for status: ApplicationStatus) -> Color {
        switch status {
        case .submitted, .underReview:
            return .orange
        case .accepted:
            return .green
        case .refused, .withdrawn:
            return .red
        }
    }
    
    private func statusTitle(for status: ApplicationStatus) -> String {
        switch status {
        case .submitted:
            return "Candidature envoyée"
        case .underReview:
            return "En cours d'examen"
        case .accepted:
            return "Candidature acceptée"
        case .refused:
            return "Candidature refusée"
        case .withdrawn:
            return "Candidature retirée"
        }
    }
    
    private func statusMessage(for status: ApplicationStatus) -> String {
        switch status {
        case .submitted:
            return "Votre candidature a été reçue et sera examinée prochainement."
        case .underReview:
            return "L'entreprise examine actuellement votre candidature."
        case .accepted:
            return "Félicitations ! Votre candidature a été acceptée."
        case .refused:
            return "Votre candidature n'a pas été retenue pour cette offre."
        case .withdrawn:
            return "Vous avez retiré votre candidature pour cette offre."
        }
    }
    
    private func applyToOffer() async {
        guard let offer = offer else { return }
        
        isApplying = true
        defer { isApplying = false }
        
        print("🔄 [OfferDetailView] Applying to offer: \(offer.id)")
        let res = await engine.applicationService.apply(toOffer: offer.id, data: [:])
        
        switch res {
        case .success(let application):
            print("✅ [OfferDetailView] Successfully applied to offer")
            
            // Analytics: Application submitted
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.applicationSubmitted,
                parameters: [
                    "offer_id": offer.id,
                    "application_id": application.id
                ]
            )
            
            myApplication = application
            showSuccessMessage = true
        case .failure(let error):
            print("❌ [OfferDetailView] Error applying to offer: \(error)")
            
            // Si erreur 400, c'est probablement parce qu'on a déjà postulé
            if case .serverError(let statusCode) = error, statusCode == 400 {
                print("⚠️ [OfferDetailView] 400 error - likely already applied")
                
                if isCompany {
                    // Company: recharger les applications
                    await checkMyApplication()
                } else {
                    // Provider: créer une application virtuelle pour refléter l'état "déjà postulé"
                    // Le bouton sera automatiquement désactivé avec "Déjà postulé"
                    await MainActor.run {
                        if let currentUserId = engine.userService.fullUser?.id,
                           let providerName = engine.userService.fullUser?.providerProfile?.displayName {
                            let now = ISO8601DateFormatter().string(from: Date())
                            myApplication = Application(
                                id: "temp_\(offer.id)_\(currentUserId)",
                                offerId: offer.id,
                                providerId: currentUserId,
                                message: nil,
                                attachments: nil,
                                status: .submitted,
                                createdAt: now,
                                updatedAt: now,
                                providerName: providerName,
                                ratingAfterContract: nil
                            )
                            print("✅ [OfferDetailView] Created virtual application for provider (already applied)")
                        } else {
                            // Fallback si on n'a pas les infos du provider
                            if let currentUserId = engine.userService.fullUser?.id {
                                let now = ISO8601DateFormatter().string(from: Date())
                                myApplication = Application(
                                    id: "temp_\(offer.id)_\(currentUserId)",
                                    offerId: offer.id,
                                    providerId: currentUserId,
                                    message: nil,
                                    attachments: nil,
                                    status: .submitted,
                                    createdAt: now,
                                    updatedAt: now,
                                    providerName: "Provider",
                                    ratingAfterContract: nil
                                )
                                print("✅ [OfferDetailView] Created virtual application for provider (fallback)")
                            }
                        }
                    }
                }
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func withdrawApplication() async {
        guard let application = myApplication else { return }
        
        isWithdrawing = true
        defer { isWithdrawing = false }
        
        print("🔄 [OfferDetailView] Withdrawing application: \(application.id)")
        let res = await engine.applicationService.withdrawApplication(id: application.id)
        
        switch res {
        case .success:
            print("✅ [OfferDetailView] Successfully withdrew application")
            // Recharger l'application pour mettre à jour le statut
            await checkMyApplication()
            
            if let updatedApp = myApplication, updatedApp.status == .withdrawn {
                print("ℹ️ [OfferDetailView] Application withdrawn, status updated")
            } else if myApplication == nil {
                print("ℹ️ [OfferDetailView] Application removed, can apply again")
            }
        case .failure(let error):
            print("❌ [OfferDetailView] Error withdrawing application: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    private func canWithdrawApplication(_ application: Application) -> Bool {
        // On peut retirer seulement si le statut est submitted, underReview, ou withdrawn
        // On ne peut pas retirer si acceptée ou refusée
        switch application.status {
        case .submitted, .underReview, .withdrawn:
            return true
        case .accepted, .refused:
            return false
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
