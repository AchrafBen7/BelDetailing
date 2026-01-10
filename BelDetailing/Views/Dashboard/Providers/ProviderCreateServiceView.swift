//
//  ProviderCreateServiceView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 25/12/2025.
//

import SwiftUI
import RswiftResources
import PhotosUI

struct ProviderCreateServiceView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var vm: ProviderCreateServiceViewModel

    let onCreated: () async -> Void

    // Etat local pour l’édition du prix
    @State private var priceText: String = ""

    // Image du service
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem? = nil

    init(engine: Engine, onCreated: @escaping () async -> Void) {
        _vm = StateObject(
            wrappedValue: ProviderCreateServiceViewModel(engine: engine)
        )
        self.onCreated = onCreated
    }

    // Grilles à colonnes fixes (uniformité des tailles)
    private let fixed3Columns = Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .center), count: 3)

    // Durations (minutes) sans doublon, ordre logique
    private let availableDurations: [Int] = [30, 60, 90, 120, 150, 180, 240]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                // BACK BUTTON
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text(R.string.localizable.commonBack())
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(height: 44)

                // HEADER
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nouveau service")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(R.color.primaryText))
                    Text("Renseignez les informations de votre prestation.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // CARD: Informations principales
                card {
                    VStack(alignment: .leading, spacing: 16) {

                        // IMAGE PICKER + PREVIEW
                        sectionLabel("Photo du service")
                        imagePickerSection

                        sectionLabel("Nom du service")
                        TextField("Nom du service", text: $vm.name)
                            .textFieldStyle(.roundedBorder)

                        sectionLabel("Description")
                        TextField("Décrivez brièvement votre service…", text: $vm.description, axis: .vertical)
                            .lineLimit(3...6)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                // CARD: Checklist dynamique
                if vm.category != nil {
                    ServiceSetupChecklistView(
                        category: vm.category,
                        durationMinutes: vm.durationMinutes,
                        price: vm.price
                    )
                    .padding(.horizontal, 20)
                }
                
                // CARD: Prix
                card {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Prix")

                        HStack(spacing: 20) {
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                vm.price = max(0, vm.price - 5)
                                syncPriceTextFromModel()
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.black)
                            }

                            Spacer()

                            // Champ d’édition du prix (entier en €)
                            HStack(spacing: 6) {
                                TextField("0", text: $priceText)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 32, weight: .bold))
                                    .frame(minWidth: 80)
                                    .onChange(of: priceText) { _ in
                                        sanitizePriceText()
                                    }
                                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidEndEditingNotification)) { _ in
                                        applyPriceTextToModel()
                                    }

                                Text("€")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color(R.color.primaryText))
                            }

                            Spacer()

                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                vm.price += 5
                                syncPriceTextFromModel()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // CARD: Catégorie — 3 colonnes fixes, largeur uniforme
                card {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Catégorie")

                        LazyVGrid(columns: fixed3Columns, alignment: .center, spacing: 12) {
                            ForEach(ServiceCategory.allCases, id: \.self) { cat in
                                SelectablePillUniform(
                                    title: cat.localizedTitle,
                                    isSelected: vm.category == cat
                                ) {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        vm.category = cat
                                    }
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                // CARD: Durée — 3 colonnes fixes, largeur uniforme
                card {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Durée")

                        LazyVGrid(columns: fixed3Columns, alignment: .center, spacing: 12) {
                            ForEach(availableDurations, id: \.self) { minutes in
                                DurationPillUniform(
                                    label: durationLabel(for: minutes),
                                    minutes: minutes,
                                    isSelected: vm.durationMinutes == minutes
                                ) {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        vm.durationMinutes = minutes
                                    }
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                // ERROR
                if let error = vm.error {
                    Text(error)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                        .padding(.top, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // CREATE BUTTON
                Button {
                    // synchroniser le champ avant envoi
                    applyPriceTextToModel()
                    Task {
                        let success = await vm.createService()
                        if success {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            await onCreated()
                            dismiss()
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    }
                } label: {
                    ZStack {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Créer le service")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(vm.isLoading)

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(R.color.mainBackground.name).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            tabBarVisibility.isHidden = true
            syncPriceTextFromModel()
        }
        .onDisappear { tabBarVisibility.isHidden = false }
        .onChange(of: photoItem) { _ in
            Task { await loadSelectedImage() }
        }
    }

    // MARK: - Subviews

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }

    // MARK: - Image picker section

    private var imagePickerSection: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemGray6))

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.black.opacity(0.7))
                        Text("Ajouter une photo")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.black)
                        Text("Recommandé: format paysage, bonne luminosité")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(height: 180) // ratio visuel 16:9 approx
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )

            HStack(spacing: 10) {
                PhotosPicker(
                    selection: $photoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text(selectedImage == nil ? "Choisir une photo" : "Remplacer la photo")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black)
                    .clipShape(Capsule())
                }

                if selectedImage != nil {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedImage = nil
                            photoItem = nil
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                            Text("Supprimer")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.black.opacity(0.15)))
                    }
                }

                Spacer()
            }
            .padding(.top, 2)
        }
    }

    // MARK: - Prix helpers

    private func syncPriceTextFromModel() {
        priceText = String(Int(vm.price.rounded()))
    }

    private func sanitizePriceText() {
        // garder uniquement les chiffres
        let digits = priceText.filter { $0.isNumber }
        if digits != priceText {
            priceText = digits
        }
    }

    private func applyPriceTextToModel() {
        // convertir en entier, fallback 0
        let intValue = Int(priceText) ?? 0
        vm.price = Double(max(0, intValue))
        // resynchroniser pour éviter les états bizarres
        syncPriceTextFromModel()
    }

    // MARK: - Image loading

    private func loadSelectedImage() async {
        guard let item = photoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let img = UIImage(data: data) {
            await MainActor.run {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    selectedImage = img
                }
            }
        }
    }

    // MARK: - Duration helpers

    private func durationLabel(for minutes: Int) -> String {
        if minutes % 60 == 0 {
            let hours = minutes / 60
            return hours == 1 ? "1 h" : "\(hours) h"
        } else {
            return "\(minutes) min"
        }
    }
}

// MARK: - Uniform “pill” components (largeur de colonne)

private struct SelectablePillUniform: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundColor(isSelected ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.black)
                            .transition(.opacity)
                    } else {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.black.opacity(0.05))
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: isSelected)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: isSelected ? .black.opacity(0.08) : .clear, radius: 6, y: 3)
    }
}

private struct DurationPillUniform: View {
    let label: String
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule(style: .continuous)
                                .fill(Color.black)
                                .transition(.opacity)
                        } else {
                            Capsule(style: .continuous)
                                .fill(Color.black.opacity(0.05))
                            Capsule(style: .continuous)
                                .stroke(Color.black.opacity(0.15), lineWidth: 1)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: isSelected)
        .contentShape(Capsule(style: .continuous))
        .shadow(color: isSelected ? .black.opacity(0.08) : .clear, radius: 6, y: 3)
    }
}
