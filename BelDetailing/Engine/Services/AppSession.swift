import Foundation
import Combine

@MainActor
final class AppSession: ObservableObject {
    static let shared = AppSession()

    @Published private(set) var user: User?
    @Published private(set) var providerId: String?
    @Published private(set) var isLoading = false

    private init() {}

    func refresh(engine: Engine) async {
        isLoading = true
        defer { isLoading = false }

        let me = await engine.userService.me()
        switch me {
        case .success(let user):
            self.user = user

            // Si provider: on résout un providerId fiable
            if user.role == .provider {
                // Fallback immédiat: user.id
                self.providerId = user.id
                // Si plus tard tu exposes un providerId distinct via un profil avec id, on pourra l’utiliser ici:
                // let prof = await engine.detailerService.getProfile(id: u.id)
                // if case let .success(detailer) = prof { self.providerId = detailer.id }
            } else {
                self.providerId = nil
            }

        case .failure:
            self.user = nil
            self.providerId = nil
        }
    }
}
