//
//  ServiceSetupChecklistView.swift
//  BelDetailing
//
//  Checklist dynamique pour guider la création d'un service
//

import SwiftUI
import RswiftResources

struct ServiceSetupChecklistView: View {
    let category: ServiceCategory?
    let durationMinutes: Int
    let price: Double
    
    @State private var checklistItems: [ChecklistItem] = []
    
    var body: some View {
        if !checklistItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "checklist")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)
                    Text("Vérifications recommandées")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(checklistItems) { item in
                        ChecklistItemRow(item: item)
                    }
                }
                .padding(16)
                .background(Color.orange.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
            }
            .onAppear {
                generateChecklist()
            }
            .onChange(of: category) { _ in generateChecklist() }
            .onChange(of: durationMinutes) { _ in generateChecklist() }
            .onChange(of: price) { _ in generateChecklist() }
        }
    }
    
    private func generateChecklist() {
        var items: [ChecklistItem] = []
        
        // 1. Vérification durée réaliste selon catégorie
        if let category = category {
            let recommendedDuration = getRecommendedDuration(for: category)
            if durationMinutes < recommendedDuration.min {
                items.append(.warning(
                    title: "Durée peut-être trop courte",
                    message: "Pour \(category.localizedTitle), une durée de \(recommendedDuration.min)-\(recommendedDuration.max) minutes est recommandée."
                ))
            } else if durationMinutes > recommendedDuration.max {
                items.append(.info(
                    title: "Durée importante",
                    message: "Assurez-vous d'avoir le temps nécessaire et les matériaux adaptés."
                ))
            } else {
                items.append(.success(
                    title: "Durée réaliste",
                    message: "La durée correspond bien à ce type de service."
                ))
            }
        }
        
        // 2. Vérification prix cohérent avec durée
        let pricePerMinute = price / Double(durationMinutes)
        if pricePerMinute < 0.5 {
            items.append(.warning(
                title: "Prix par minute faible",
                message: "Votre tarif est de \(String(format: "%.2f", pricePerMinute))€/min. Assurez-vous qu'il couvre vos coûts."
            ))
        } else if pricePerMinute > 3.0 {
            items.append(.info(
                title: "Prix premium",
                message: "Tarif élevé, justifiez la valeur ajoutée dans la description."
            ))
        } else {
            items.append(.success(
                title: "Prix cohérent",
                message: "Le tarif semble approprié pour la durée."
            ))
        }
        
        // 3. Matériaux nécessaires selon catégorie
        if let category = category {
            let materials = getRequiredMaterials(for: category)
            if !materials.isEmpty {
                items.append(.info(
                    title: "Matériaux nécessaires",
                    message: materials.joined(separator: ", ")
                ))
            }
        }
        
        // 4. Temps de séchage si applicable
        if let category = category, requiresDryingTime(category: category) {
            items.append(.info(
                title: "Temps de séchage",
                message: "Prévoyez un temps de séchage de 30-60 minutes après l'intervention."
            ))
        }
        
        // 5. Avertissements spécifiques par catégorie
        if let category = category {
            let warnings = getCategoryWarnings(for: category, duration: durationMinutes, price: price)
            items.append(contentsOf: warnings)
        }
        
        checklistItems = items
    }
    
    // MARK: - Helper Functions
    
    private func getRecommendedDuration(for category: ServiceCategory) -> (min: Int, max: Int) {
        switch category {
        case .carCleaning:
            return (30, 60)
        case .interiorDetailing:
            return (60, 120)
        case .exteriorDetailing:
            return (60, 120)
        case .carPolishing:
            return (90, 180)
        case .ceramicCoating:
            return (180, 300)
        case .paintCorrection:
            return (120, 240)
        case .headlightRestoration:
            return (60, 90)
        case .engineBay:
            return (45, 90)
        case .wheelsTires:
            return (45, 90)
        case .waxSealant:
            return (60, 120)
        }
    }
    
    private func getRequiredMaterials(for category: ServiceCategory) -> [String] {
        switch category {
        case .carCleaning:
            return ["Shampooing auto", "Éponge microfibre", "Séchage microfibre"]
        case .interiorDetailing:
            return ["Aspirateur", "Produits nettoyants", "Brosses spécialisées"]
        case .exteriorDetailing:
            return ["Shampooing auto", "Éponge microfibre", "Séchage microfibre"]
        case .carPolishing:
            return ["Polisseuse", "Pâtes de polissage", "Pad de polissage"]
        case .ceramicCoating:
            return ["Produit céramique", "Applicateurs", "Lampe UV (optionnel)"]
        case .paintCorrection:
            return ["Polisseuse", "Pâtes abrasives", "Pads variés"]
        case .headlightRestoration:
            return ["Papier abrasif", "Polisseuse", "Produit de protection"]
        case .engineBay:
            return ["Dégrippant", "Brosses", "Protection électronique"]
        case .wheelsTires:
            return ["Nettoyant jantes", "Brosses spéciales", "Protecteur pneus"]
        case .waxSealant:
            return ["Cire ou scellant", "Applicateurs", "Microfibres"]
        }
    }
    
    private func requiresDryingTime(category: ServiceCategory) -> Bool {
        switch category {
        case .ceramicCoating, .carPolishing, .paintCorrection:
            return true
        default:
            return false
        }
    }
    
    private func getCategoryWarnings(for category: ServiceCategory, duration: Int, price: Double) -> [ChecklistItem] {
        var warnings: [ChecklistItem] = []
        
        switch category {
        case .ceramicCoating:
            if duration < 180 {
                warnings.append(.warning(
                    title: "Céramique nécessite du temps",
                    message: "Un coating céramique prend généralement 3-5 heures. Vérifiez votre durée."
                ))
            }
            if price < 200 {
                warnings.append(.warning(
                    title: "Prix peut-être trop bas",
                    message: "Les produits céramiques sont coûteux. Assurez-vous de couvrir vos coûts."
                ))
            }
            
        case .paintCorrection:
            if duration < 120 {
                warnings.append(.warning(
                    title: "Correction peinture intensive",
                    message: "La correction de peinture nécessite généralement 2-4 heures selon l'état."
                ))
            }
            
        case .carPolishing:
            if price < 80 && duration > 120 {
                warnings.append(.info(
                    title: "Tarif attractif",
                    message: "Pour une durée de \(duration) minutes, votre prix est compétitif."
                ))
            }
            
        default:
            break
        }
        
        return warnings
    }
}

// MARK: - Checklist Item Model

enum ChecklistItem: Identifiable {
    case success(title: String, message: String)
    case warning(title: String, message: String)
    case info(title: String, message: String)
    
    var id: String {
        switch self {
        case .success(let title, _), .warning(let title, _), .info(let title, _):
            return title
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .success: return .green
        case .warning: return .orange
        case .info: return .blue
        }
    }
    
    var title: String {
        switch self {
        case .success(let title, _), .warning(let title, _), .info(let title, _):
            return title
        }
    }
    
    var message: String {
        switch self {
        case .success(_, let message), .warning(_, let message), .info(_, let message):
            return message
        }
    }
}

// MARK: - Checklist Item Row

private struct ChecklistItemRow: View {
    let item: ChecklistItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 18))
                .foregroundColor(item.iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(item.message)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

