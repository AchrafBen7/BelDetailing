//
//  SupportView.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import SwiftUI
import RswiftResources
import MessageUI

struct SupportView: View {
    let engine: Engine
    @StateObject private var viewModel: SupportViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    @State private var searchText: String = ""
    @State private var showMailComposer = false
    @State private var showEmailAlert = false
    @State private var showPhoneCall = false
    
    init(engine: Engine) {
        self.engine = engine
        _viewModel = StateObject(wrappedValue: SupportViewModel(engine: engine))
    }
    
    var body: some View {
        ZStack {
            // Fond global clair
            Color(R.color.mainBackground.name)
                .ignoresSafeArea()
                // Bande noire qui va jusqu’en haut (sous la status bar)
                .overlay(
                    Color.black
                        .frame(height: 240) // hauteur suffisante pour couvrir header + safe area
                        .ignoresSafeArea(edges: .top),
                    alignment: .top
                )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header noir avec barre de recherche
                    header
                    
                    // Contenu sur fond clair
                    VStack(spacing: 24) {
                        // Actions rapides
                        quickActionsSection
                        
                        // Questions fréquentes
                        faqSection
                        
                        // Nous contacter
                        contactSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
        .sheet(isPresented: $showMailComposer) {
            if MFMailComposeViewController.canSendMail() {
                MailComposeView(
                    recipients: [viewModel.supportEmail],
                    subject: "",
                    messageBody: ""
                )
            }
        }
        .alert("Email non disponible", isPresented: $showEmailAlert) {
            Button(R.string.localizable.commonOk(), role: .cancel) {}
        } message: {
            Text("Aucun compte e‑mail configuré sur cet appareil.")
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Assistance")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Comment pouvons-nous vous aider ?")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Barre de recherche
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                TextField("", text: $searchText, prompt: Text("Rechercher une aide...").foregroundColor(.gray.opacity(0.6)))
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(20)
        .background(
            // Coins arrondis en bas pour le header
            RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight])
                .fill(Color.black)
        )
        .padding(.bottom, 1)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions rapides")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                QuickActionCard(
                    icon: "calendar.badge.exclamationmark",
                    title: "Problème de réservation",
                    color: .orange
                ) {
                    // Navigation vers réservations
                }
                
                QuickActionCard(
                    icon: "creditcard.fill",
                    title: "Paiement",
                    color: .blue
                ) {
                    // Navigation vers paiements
                }
                
                QuickActionCard(
                    icon: "timer",
                    title: "Service en cours",
                    color: .green
                ) {
                    // Navigation vers services en cours
                }
                
                QuickActionCard(
                    icon: "bag.fill",
                    title: "Commande boutique",
                    color: .purple
                ) {
                    // Navigation vers commandes
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - FAQ Section
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Questions fréquentes")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                FAQItem(
                    question: "Comment annuler une réservation ?",
                    answer: "Vous pouvez annuler votre réservation depuis la page 'Mes réservations'. Les conditions d'annulation dépendent du délai avant le service. Une annulation gratuite est possible jusqu'à 24h avant le rendez-vous."
                )
                
                FAQItem(
                    question: "Comment modifier la date de mon service ?",
                    answer: "Accédez à votre réservation et cliquez sur 'Modifier'. Vous pourrez choisir une nouvelle date selon les disponibilités du prestataire."
                )
                
                FAQItem(
                    question: "Comment obtenir un remboursement ?",
                    answer: "Les remboursements sont traités sous 5-7 jours ouvrés. Si vous n'avez pas reçu votre remboursement après ce délai, contactez notre support."
                )
                
                FAQItem(
                    question: "Comment suivre ma commande boutique ?",
                    answer: "Rendez-vous dans 'Mes commandes' pour voir le statut de votre livraison. Vous recevrez également des notifications à chaque étape."
                )
                
                FAQItem(
                    question: "Comment devenir prestataire NIOS ?",
                    answer: "Téléchargez l'application et créez un compte prestataire. Suivez les étapes de vérification et commencez à proposer vos services."
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Contact Section
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Nous contacter")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                // Chat en direct
                ContactActionCard(
                    icon: "message.fill",
                    iconColor: .blue,
                    title: "Chat en direct",
                    subtitle: "Réponse en moins de 5 min",
                    status: "Disponible",
                    statusColor: .green
                ) {
                    // Action chat
                }
                
                // Appeler le support
                ContactActionCard(
                    icon: "phone.fill",
                    iconColor: .green,
                    title: "Appeler le support",
                    subtitle: viewModel.supportPhone ?? "+33 1 23 45 67 89",
                    status: "Disponible",
                    statusColor: .green
                ) {
                    viewModel.callPhone()
                }
                
                // Email
                ContactActionCard(
                    icon: "envelope.fill",
                    iconColor: .orange,
                    title: "Email",
                    subtitle: viewModel.supportEmail,
                    status: "Disponible",
                    statusColor: .green
                ) {
                    if MFMailComposeViewController.canSendMail() {
                        showMailComposer = true
                    } else {
                        showEmailAlert = true
                    }
                }
                
                // Horaires
                ContactHoursCard()
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Quick Action Card
private struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)
                    .frame(height: 40)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FAQ Item
private struct FAQItem: View {
    let question: String
    let answer: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Text(question)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding(20)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

// MARK: - Contact Action Card
private struct ContactActionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let status: String
    let statusColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status badge
                Text(status)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Contact Hours Card
private struct ContactHoursCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.orange)
                    .frame(width: 50, height: 50)
                
                Text("Horaires du support")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Lundi - Vendredi : 8h - 20h")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text("Samedi - Dimanche : 9h - 18h")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}


// MARK: - Mail Compose View (UIViewControllerRepresentable)
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let messageBody: String
    
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            dismiss()
        }
    }
}
