//  TaxesView.swift

import SwiftUI
import RswiftResources
import Combine

// MARK: - DateFormatter helper
extension DateFormatter {
    static let yearMonth: DateFormatter = {
        let time = DateFormatter()
        time.dateFormat = "yyyy-MM"
        time.locale = Locale(identifier: "en_US_POSIX")
        return time
    }()
}

@MainActor
final class TaxesViewModel: ObservableObject {
    let engine: Engine
    
    @Published var vatNumber: String = ""
    @Published var invoices: [Invoice] = []
    @Published var isSaving = false

    // Taxes
    @Published var selectedMonth: String = DateFormatter.yearMonth.string(from: Date())
    @Published var summary: TaxSummary?
    @Published var documents: [TaxDocument] = []
    @Published var isLoading: Bool = false
    @Published var errorText: String?
    @Published var downloadedFileURL: URL?

    init(engine: Engine) {
        self.engine = engine
        loadInitial()
        Task { await loadMonth() }
    }
    
    private func loadInitial() {
        if let user = engine.userService.currentUser,
           let vat = user.vatNumber {
            vatNumber = vat
        }
    }
    
    func saveVAT() async {
        guard !vatNumber.isEmpty else { return }
        isSaving = true
        let response = await engine.userService.validateVAT(vatNumber)
        isSaving = false
        print("VAT validation response: \(response)")
    }

    // MARK: - Month handling
    var selectedMonthLabel: String {
        let parts = selectedMonth.split(separator: "-")
        guard parts.count == 2 else { return selectedMonth }
        return "\(parts[1]) / \(parts[0])"
    }

    func changeMonth(by value: Int) {
        guard let date = DateFormatter.yearMonth.date(from: selectedMonth),
              let newDate = Calendar.current.date(byAdding: .month, value: value, to: date)
        else { return }
        selectedMonth = DateFormatter.yearMonth.string(from: newDate)
        Task { await loadMonth() }
    }

    // MARK: - Loading summary + documents
    func loadMonth() async {
        isLoading = true
        defer { isLoading = false }

        async let summaryRes: APIResponse<TaxSummary> = engine.networkClient.call(
            endPoint: .taxesSummary,
            urlDict: ["month": selectedMonth]
        )

        async let docsRes: APIResponse<[TaxDocument]> = engine.networkClient.call(
            endPoint: .taxesDocuments,
            urlDict: ["month": selectedMonth],
            wrappedInData: true
        )

        let (summaryResult, docsResult) = await (summaryRes, docsRes)

        switch summaryResult {
        case .success(let sum):
            summary = sum
        case .failure(let err):
            print("❌ taxesSummary error:", err)
            summary = nil
        }

        switch docsResult {
        case .success(let docs):
            documents = docs
        case .failure(let err):
            print("❌ taxesDocuments error:", err)
            documents = []
        }
    }

    // MARK: - Download protégé + progression
    func download(_ doc: TaxDocument) async {
        // Fermer le clavier si ouvert
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        isLoading = true
        defer { isLoading = false }

        let res: APIResponse<Data> = await engine.networkClient.downloadWithProgress(
            endPoint: .taxesDownload(id: doc.id),
            urlDict: ["month": selectedMonth]
        )

        switch res {
        case .success(let data):
            do {
                let safeName = sanitizedFileName("\(doc.title)-\(doc.id).pdf")
                let fileURL = try saveToCache(data: data, suggestedName: safeName)
                downloadedFileURL = fileURL
            } catch {
                errorText = error.localizedDescription
            }
        case .failure(let err):
            errorText = err.localizedDescription
        }
    }

    private func saveToCache(data: Data, suggestedName: String) throws -> URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let url = dir.appendingPathComponent(suggestedName)
        try data.write(to: url, options: .atomic)
        return url
    }

    private func sanitizedFileName(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        return name.components(separatedBy: invalid).joined(separator: "_")
    }
}

struct TaxesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: TaxesViewModel
    
    init(engine: Engine) {
        _vm = StateObject(wrappedValue: TaxesViewModel(engine: engine))
    }
    
    var body: some View {
        ZStack {
            // Fond global clair
            Color(R.color.mainBackground.name)
                .ignoresSafeArea()
                // Bande noire qui va jusqu'en haut (sous la status bar)
                .overlay(
                    Color.black
                        .frame(height: 240)
                        .ignoresSafeArea(edges: .top),
                    alignment: .top
                )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header noir
                    header

                    // Contenu
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - Sélecteur de mois
                        monthSelector

                        // MARK: - Résumé (optionnel si backend fournit)
                        if let sum = vm.summary {
                            summaryCard(sum)
                        }

                        // MARK: - TVA Card (existant)
                        vatCard

                        // MARK: - Invoices (existant)
                        invoicesSection

                        // MARK: - Documents (nouvelle logique sans mock)
                        documentsSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: Binding(
            get: { vm.downloadedFileURL.map { FileWrapperItem(url: $0) } },
            set: { _ in vm.downloadedFileURL = nil }
        )) { item in
            ShareLink(item: item.url) { Text("Partager") }
                .padding()
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
                Text(R.string.localizable.taxesTitle())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(R.string.localizable.taxesSubtitle())
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(20)
        .background(
            RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight])
                .fill(Color.black)
        )
        .padding(.bottom, 1)
    }

    // MARK: - Month selector
    private var monthSelector: some View {
        HStack {
            Button { vm.changeMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
            }

            Spacer()

            Text(vm.selectedMonthLabel)
                .font(.system(size: 16, weight: .semibold))

            Spacer()

            Button { vm.changeMonth(by: 1) } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    // MARK: - Summary card (optionnel)
    private func summaryCard(_ sum: TaxSummary) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Résumé — \(vm.selectedMonthLabel)")
                .font(.system(size: 18, weight: .semibold))
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Revenu").font(.system(size: 14)).foregroundColor(.gray)
                    Text("\(Int(sum.revenue))€").font(.system(size: 18, weight: .bold))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Services").font(.system(size: 14)).foregroundColor(.gray)
                    Text("\(sum.servicesCount)").font(.system(size: 18, weight: .bold))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Commissions").font(.system(size: 14)).foregroundColor(.gray)
                    Text("\(Int(sum.commissions))€").font(.system(size: 18, weight: .bold))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Net").font(.system(size: 14)).foregroundColor(.gray)
                    Text("\(Int(sum.net))€").font(.system(size: 18, weight: .bold))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }

    // MARK: - VAT card (existant)
    private var vatCard: some View {
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
    }

    // MARK: - Invoices (existant)
    private var invoicesSection: some View {
        VStack(spacing: 0) {
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
        }
    }

    // MARK: - Documents (sans mock + états)
    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "doc.text")
                Text("Documents")
                    .font(.system(size: 20, weight: .bold))
            }

            if vm.isLoading {
                ProgressView()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            } else if vm.documents.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)

                    Text("Aucun document disponible")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Il n’y a pas encore de données comptables pour ce mois.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            } else {
                VStack(spacing: 0) {
                    ForEach(vm.documents) { doc in
                        TaxDocumentRow(doc: doc) {
                            Task { await vm.download(doc) }
                        }

                        if doc.id != vm.documents.last?.id {
                            Divider().padding(.leading, 74)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
            }
        }
    }
}

struct TaxDocumentRow: View {
    let doc: TaxDocument
    let onDownload: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
                    .frame(width: 44, height: 44)

                Image(systemName: "doc.text")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(doc.title)
                    .font(.system(size: 16, weight: .semibold))

                Text(doc.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("\(Int(doc.amount))€")
                .font(.system(size: 16, weight: .semibold))

            Button { onDownload() } label: {
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(.plain)
            .padding(.leading, 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct FileWrapperItem: Identifiable {
    let id = UUID()
    let url: URL
}
