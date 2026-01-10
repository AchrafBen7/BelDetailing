//
//  OfferCreateView.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import SwiftUI
import RswiftResources

struct OfferCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabBarVisibility: TabBarVisibility
    @StateObject private var vm: OfferCreateViewModel
    
    let onCreated: () async -> Void
    
    @State private var priceMinText: String = ""
    @State private var priceMaxText: String = ""
    
    private let fixed3Columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    init(engine: Engine, onCreated: @escaping () async -> Void) {
        _vm = StateObject(wrappedValue: OfferCreateViewModel(engine: engine))
        self.onCreated = onCreated
    }
    
    var body: some View {
        ZStack {
            Color(R.color.mainBackground.name).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Header
                    header
                    
                    // MARK: - Title & Description
                    card {
                        VStack(alignment: .leading, spacing: 20) {
                            sectionLabel("Titre de l’offre")
                            TextField("", text: $vm.title, prompt: Text("Entrez le titre de votre offre").foregroundColor(.gray.opacity(0.6)))
                                .font(.system(size: 16))
                                .padding(14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            
                            sectionLabel("Description")
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.systemGray6))
                                    .frame(minHeight: 120)
                                
                                if vm.description.isEmpty {
                                    Text("Décrivez votre offre (détails, exigences, etc.)")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 10)
                                        .padding(.top, 10)
                                }
                                
                                TextEditor(text: $vm.description)
                                    .font(.system(size: 16))
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 120)
                                    .padding(4)
                            }
                        }
                    }
                    
                    // MARK: - Category
                    card {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("Catégorie")
                            LazyVGrid(columns: fixed3Columns, spacing: 12) {
                                ForEach(ServiceCategory.allCases, id: \.self) { cat in
                                    SelectablePill(
                                        title: cat.localizedTitle,
                                        isSelected: vm.category == cat
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            vm.category = cat
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Type
                    card {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("Type d’offre")
                            HStack(spacing: 12) {
                                ForEach(OfferType.allCases, id: \.self) { type in
                                    SelectablePill(
                                        title: type.localizedTitle,
                                        isSelected: vm.type == type
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            vm.type = type
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Vehicle Count
                    card {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionLabel("Nombre de véhicules")
                            HStack {
                                Button {
                                    if vm.vehicleCount > 1 {
                                        withAnimation {
                                            vm.vehicleCount -= 1
                                        }
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(vm.vehicleCount > 1 ? .black : .gray.opacity(0.3))
                                }
                                .disabled(vm.vehicleCount <= 1)
                                
                                Spacer()
                                
                                Text("\(vm.vehicleCount)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(minWidth: 60)
                                
                                Spacer()
                                
                                Button {
                                    if vm.vehicleCount < 100 {
                                        withAnimation {
                                            vm.vehicleCount += 1
                                        }
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(vm.vehicleCount < 100 ? .black : .gray.opacity(0.3))
                                }
                                .disabled(vm.vehicleCount >= 100)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // MARK: - Price Range
                    card {
                        VStack(alignment: .leading, spacing: 20) {
                            sectionLabel("Fourchette de prix")
                            
                            VStack(spacing: 16) {
                                // Min Price
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Prix minimum")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 12) {
                                        TextField("", text: $priceMinText, prompt: Text("100").foregroundColor(.gray.opacity(0.6)))
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 18, weight: .semibold))
                                            .padding(14)
                                            .background(Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .onChange(of: priceMinText) { _, newValue in
                                                let filtered = newValue.filter { $0.isNumber }
                                                if filtered != newValue {
                                                    priceMinText = filtered
                                                }
                                                if let value = Double(filtered) {
                                                    vm.priceMin = max(0, value)
                                                    if vm.priceMax < vm.priceMin {
                                                        vm.priceMax = vm.priceMin
                                                        priceMaxText = String(Int(vm.priceMax))
                                                    }
                                                }
                                            }
                                        
                                        Text("€")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                // Max Price
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Prix maximum")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 12) {
                                        TextField("", text: $priceMaxText, prompt: Text("500").foregroundColor(.gray.opacity(0.6)))
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 18, weight: .semibold))
                                            .padding(14)
                                            .background(Color(.systemGray6))
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .onChange(of: priceMaxText) { _, newValue in
                                                let filtered = newValue.filter { $0.isNumber }
                                                if filtered != newValue {
                                                    priceMaxText = filtered
                                                }
                                                if let value = Double(filtered) {
                                                    vm.priceMax = max(vm.priceMin, value)
                                                }
                                            }
                                        
                                        Text("€")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Location
                    card {
                        VStack(alignment: .leading, spacing: 20) {
                            sectionLabel("Localisation")
                            
                            VStack(spacing: 16) {
                                TextField("", text: $vm.city, prompt: Text("Ville (ex: Bruxelles)").foregroundColor(.gray.opacity(0.6)))
                                    .font(.system(size: 16))
                                    .padding(14)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                
                                TextField("", text: $vm.postalCode, prompt: Text("Code postal (ex: 1000)").foregroundColor(.gray.opacity(0.6)))
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16))
                                    .padding(14)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                    }
                    
                    // MARK: - Error
                    if let error = vm.error {
                        Text(error)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Create Button
                    Button {
                        Task {
                            let success = await vm.createOffer()
                            if success {
                                await onCreated()
                                dismiss()
                            }
                        }
                    } label: {
                        ZStack {
                            if vm.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Publier l’offre")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(vm.canCreate ? Color.black : Color.gray.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: vm.canCreate ? .black.opacity(0.2) : .clear, radius: 8, y: 4)
                    }
                    .disabled(!vm.canCreate || vm.isLoading)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            tabBarVisibility.isHidden = true
            priceMinText = String(Int(vm.priceMin))
            priceMaxText = String(Int(vm.priceMax))
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.vertical, 4)
            }
            
            Spacer()
        }
        .overlay(
            VStack(spacing: 4) {
                Text("Créer une offre")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(R.color.primaryText))
                
                Text("Renseignez les informations de votre offre")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
        )
        .padding(.horizontal, 20)
    }
    
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        .padding(.horizontal, 20)
    }
}

// MARK: - Selectable Pill Component
private struct SelectablePill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black)
                        } else {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.05))
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .shadow(color: isSelected ? .black.opacity(0.1) : .clear, radius: 4, y: 2)
    }
}
