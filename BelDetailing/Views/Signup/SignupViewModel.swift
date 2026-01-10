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
    
    enum SignupError: LocalizedError {
        case accountExists
        case message(String)
        
        var errorDescription: String? {
            switch self {
            case .accountExists:
                return "account_exists"
            case .message(let msg):
                return msg
            }
        }
    }
    
    func registerUser(data: SignupData) async throws -> String {
        var payload = buildBasePayload(data: data)
        
        if let vatNumber = data.vatNumber, !vatNumber.isEmpty {
            payload["vat_number"] = vatNumber
        }
        
        // Add role-specific profiles
        if let role = selectedRole {
            switch role {
            case .customer:
                if let customerProfile = buildCustomerProfile(data: data) {
                    payload["customer_profile"] = customerProfile
                }
            case .company:
                if let companyProfile = buildCompanyProfile(data: data) {
                    payload["company_profile"] = companyProfile
                }
            case .provider:
                if let providerProfile = buildProviderProfile(data: data) {
                    payload["provider_profile"] = providerProfile
                }
            }
        }
        
        let result: APIResponse<RegisterResponse> = await userService.register(payload: payload)
        
        switch result {
        case .success(let response):
            print("🔍 [SIGNUP] RegisterResponse received:")
            print("  - success: \(response.success)")
            print("  - email: '\(response.email)'")
            print("  - role: '\(response.role)'")
            
            // Analytics: User signed up
            FirebaseManager.shared.logEvent(
                FirebaseManager.Event.userSignedUp,
                parameters: [
                    "role": response.role,
                    "method": "email"
                ]
            )
            
            // Vérifier que l'email n'est pas vide
            if response.email.isEmpty {
                print("⚠️ [SIGNUP] WARNING: RegisterResponse.email is empty!")
                // Fallback : utiliser l'email du payload
                if let emailFromPayload = payload["email"] as? String, !emailFromPayload.isEmpty {
                    print("🔍 [SIGNUP] Using email from payload: '\(emailFromPayload)'")
                    return emailFromPayload
                }
            }
            
            return response.email
        case .failure(let error):
            let errorMessage = error.localizedDescription.lowercased()
            if errorMessage.contains("already") || errorMessage.contains("exists") || errorMessage.contains("déjà") || errorMessage.contains("existe") {
                throw SignupError.accountExists
            }
            throw SignupError.message(error.localizedDescription)
        }
    }
    
    // MARK: - Payload Building Helpers
    
    private func buildBasePayload(data: SignupData) -> [String: Any] {
        [
            "email": data.email,
            "password": data.password,
            "phone": data.phone,
            "role": selectedRole?.rawValue ?? "customer"
        ]
    }
    
    private func buildCustomerProfile(data: SignupData) -> [String: Any]? {
        var profile: [String: Any] = [:]
        
        if let firstName = data.customerFirstName, !firstName.isEmpty {
            profile["first_name"] = firstName
        }
        if let lastName = data.customerLastName, !lastName.isEmpty {
            profile["last_name"] = lastName
        }
        if let vehicleType = data.customerVehicleType {
            profile["vehicle_type"] = vehicleType.rawValue
        }
        if let address = data.customerAddress, !address.isEmpty {
            profile["default_address"] = address
        }
        
        return profile.isEmpty ? nil : profile
    }
    
    private func buildCompanyProfile(data: SignupData) -> [String: Any]? {
        var profile: [String: Any] = [:]
        
        if let legalName = data.companyLegalName, !legalName.isEmpty {
            profile["legal_name"] = legalName
        }
        if let typeId = data.companyTypeId, !typeId.isEmpty {
            profile["company_type_id"] = typeId
        }
        if let city = data.companyCity, !city.isEmpty {
            profile["city"] = city
        }
        if let postalCode = data.companyPostalCode, !postalCode.isEmpty {
            profile["postal_code"] = postalCode
        }
        if let contactName = data.companyContactName, !contactName.isEmpty {
            profile["contact_name"] = contactName
        }
        
        return profile.isEmpty ? nil : profile
    }
    
    private func buildProviderProfile(data: SignupData) -> [String: Any]? {
        var profile: [String: Any] = [:]
        
        if let displayName = data.providerDisplayName, !displayName.isEmpty {
            profile["display_name"] = displayName
        }
        if let baseCity = data.providerBaseCity, !baseCity.isEmpty {
            profile["base_city"] = baseCity
        }
        if let postalCode = data.providerPostalCode, !postalCode.isEmpty {
            profile["postal_code"] = postalCode
        }
        if let minPrice = data.providerMinPrice, minPrice > 0 {
            profile["min_price"] = minPrice
        }
        if let hasMobileService = data.providerHasMobileService {
            profile["has_mobile_service"] = hasMobileService
        }
        // Note: transport_price_per_km n'est plus utilisé - les frais sont fixes (zones avec plafond 20€)
        if let companyName = data.providerCompanyName, !companyName.isEmpty {
            profile["company_name"] = companyName
        }
        if let bio = data.providerBio, !bio.isEmpty {
            profile["bio"] = bio
        }
        
        return profile.isEmpty ? nil : profile
    }
}
