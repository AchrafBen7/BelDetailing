import Foundation
import Combine
@MainActor
final class SignupViewModel: ObservableObject {
    @Published var selectedRole: UserRole?
    
    private let userService: UserService
    
    init(engine: Engine, initialRole: UserRole? = nil) {
        self.userService = engine.userService
        self.selectedRole = initialRole
    }
    
    func registerUser(
        email: String,
        password: String,
        phone: String,
        vatNumber: String?
    ) async -> String? {
        
        var payload: [String: Any] = [
            "email": email,
            "password": password,
            "phone": phone,
            "role": selectedRole?.rawValue ?? "customer"
        ]
        
        if let vatNumber, !vatNumber.isEmpty {
            payload["vat_number"] = vatNumber
        }
        
        let result: APIResponse<RegisterResponse> = await userService.register(payload: payload)
        
        switch result {
        case .success(let response):
            return response.email   // 🔥 On remonte l’email vers SignupFormView
        case .failure:
            return nil
        }
    }
}
