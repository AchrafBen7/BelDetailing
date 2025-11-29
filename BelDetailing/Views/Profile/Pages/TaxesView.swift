//  TaxesView.swift

import SwiftUI
import RswiftResources
import Combine

@MainActor
final class TaxesViewModel: ObservableObject {
    private let engine: Engine
    
    @Published var vatNumber: String = ""
    @Published var invoices: [Invoice] = []
    @Published var isSaving = false
    
    init(engine: Engine) {
        self.engine = engine
        loadInitial()
    }
    
    private func loadInitial() {
        if let user = engine.userService.currentUser,
           let vat = user.vatNumber {
            vatNumber = vat
        }
        invoices = Invoice.sampleValues
    }
    
    func saveVAT() async {
        guard !vatNumber.isEmpty else { return }
        isSaving = true
        let response = await engine.userService.validateVAT(vatNumber)
        // plus tard: gérer la réponse correctement (toast, erreur, etc.)
        isSaving = false
        print("VAT validation response: \(response)")
    }
}

struct TaxesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: TaxesViewModel
    
    init(engine: Engine) {
        _vm = StateObject(wrappedValue: TaxesViewModel(engine: engine))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(R.string.localizable.taxesTitle())
                            .font(.system(size: 28, weight: .bold))
                        Text(R.string.localizable.taxesSubtitle())
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                    
                    // MARK: - TVA Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(R.string.localizable.taxesVatLabel())
                            .font(.system(size: 16, weight: .semibold))
                        
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemGray6))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            TextField(
                                R.string.localizable.taxesVatPlaceholder(),
                                text: $vm.vatNumber
                            )
                            .font(.system(size: 16))
                            .textInputAutocapitalization(.characters)
                            .disableAutocorrection(true)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        
                        Text(R.string.localizable.taxesVatFormatHelp())
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        
                        Button {
                            Task { await vm.saveVAT() }
                        } label: {
                            Text(R.string.localizable.taxesSaveButton())
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                    
                    // MARK: - Invoices
                    Text(R.string.localizable.taxesInvoicesTitle())
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.top, 8)
                    
                    VStack(spacing: 0) {
                        ForEach(vm.invoices) { invoice in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(invoice.id)
                                        .font(.system(size: 16, weight: .semibold))
                                    
                                    Text(invoice.title)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Text(DateFormatters.shortDate.string(from: invoice.date))
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("\(Int(invoice.amount))€")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Image(systemName: "arrow.down.to.line")
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.leading, 8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            if invoice.id != vm.invoices.last?.id {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .padding(.top, 8)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}
