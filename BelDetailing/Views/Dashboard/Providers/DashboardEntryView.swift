import SwiftUI
import Combine

@MainActor
final class DashboardEntryViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var role: UserRole?

    let engine: Engine
    init(engine: Engine) { self.engine = engine }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        // 1) if already cached
        if let user = engine.userService.fullUser {
            role = user.role
            return
        }

        // 2) otherwise, fetch profile
        let res = await engine.userService.me()
        if case let .success(use) = res {
            role = use.role
        } else {
            role = nil
        }
    }
}

struct DashboardEntryView: View {
    let engine: Engine
    @StateObject private var vm: DashboardEntryViewModel
    @StateObject private var session = AppSession.shared

    init(engine: Engine) {
        self.engine = engine
        _vm = StateObject(wrappedValue: DashboardEntryViewModel(engine: engine))
    }

    var body: some View {
        Group {
            if vm.isLoading || session.isLoading {
                ProgressView().padding(.top, 40)
            } else if let role = vm.role {
                switch role {
                case .provider:
                    if let providerId = session.providerId {
                        DashboardProviderView(engine: engine, providerId: providerId)
                    } else {
                        Text("Provider profile not found").foregroundColor(.gray)
                    }

                case .company:
                    CompanyDashboardView(engine: engine)

                case .customer:
                    CustomerDashboardView(engine: engine)
                }
            } else {
                // Not logged in / session missing
                Text("Please login").padding()
            }
        }
        .task {
            // Load role via UserService
            await vm.load()
            // Ensure session has providerId ready for provider route
            await session.refresh(engine: engine)
        }
    }
}
