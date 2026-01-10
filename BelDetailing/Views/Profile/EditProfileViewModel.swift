import Foundation
import Combine
import CoreLocation

@MainActor
final class EditProfileViewModel: ObservableObject {

    // Inputs
    let engine: Engine
    let user: User

    // UI
    @Published var isSaving = false
    @Published var errorText: String?
    @Published var toast: ToastState?

    // COMMON
    @Published var phone: String = ""
    @Published var vatNumber: String = ""

    // CUSTOMER
    @Published var customerFirstName: String = ""
    @Published var customerLastName: String = ""
    @Published var customerAddress: String = ""
    @Published var customerVehicleType: VehicleType?

    // COMPANY
    @Published var companyLegalName: String = ""
    @Published var companyTypeId: String = ""
    @Published var companyCity: String = ""
    @Published var companyPostalCode: String = ""
    @Published var companyContactName: String = ""

    // PROVIDER - base
    @Published var providerDisplayName: String = ""
    @Published var providerBio: String = ""
    @Published var providerBaseCity: String = ""
    @Published var providerPostalCode: String = ""
    @Published var providerHasMobileService: Bool = false
    @Published var providerMinPrice: Double = 0
    @Published var providerServices: [String] = []

    // PROVIDER - nouveaux champs
    @Published var providerCompanyName: String = ""
    @Published var providerTeamSize: Int = 1
    @Published var providerYearsOfExperience: Int = 0
    @Published var providerLogoUrl: String?
    @Published var providerBannerUrl: String?
    @Published var providerEmail: String = ""
    @Published var providerOpeningHours: String = ""
    @Published var providerTransportPricePerKm: Double = 2.0
    @Published var providerTransportEnabled: Bool = true

    // Upload state (images)
    @Published var selectedLogoData: Data?
    @Published var selectedBannerData: Data?

    // Activity indicators
    @Published var isUploadingLogo = false
    @Published var isUploadingBanner = false
    @Published var isGeocoding = false

    // Internal geocoding result (not directly editable)
    private var geoLat: Double?
    private var geoLng: Double?

    init(engine: Engine, user: User) {
        self.engine = engine
        self.user = user
        hydrate(from: user)
    }

    func hydrate(from user: User) {
        // Common
        phone = user.phone ?? ""
        vatNumber = user.vatNumber ?? ""

        // Customer
        if let customer = user.customerProfile {
            customerFirstName = customer.firstName
            customerLastName = customer.lastName
            customerAddress = customer.defaultAddress ?? ""
            customerVehicleType = customer.vehicleType
        }

        // Company
        if let company = user.companyProfile {
            companyLegalName = company.legalName
            companyTypeId = company.companyTypeId
            companyCity = company.city ?? ""
            companyPostalCode = company.postalCode ?? ""
            companyContactName = company.contactName ?? ""
        }

        // Provider
        if let provider = user.providerProfile {
            providerDisplayName = provider.displayName
            providerBio = provider.bio ?? ""
            providerBaseCity = provider.baseCity ?? ""
            providerPostalCode = provider.postalCode ?? ""
            providerHasMobileService = provider.hasMobileService
            providerMinPrice = provider.minPrice ?? 0
            providerServices = provider.services ?? []

            // Champs supplémentaires (non fournis par User.ProviderProfile)
            providerCompanyName = ""
            providerTeamSize = 1
            providerYearsOfExperience = 0
            providerLogoUrl = nil
            providerBannerUrl = nil
            providerEmail = user.email
            providerOpeningHours = ""
        } else {
            providerDisplayName = ""
            providerBio = ""
            providerBaseCity = ""
            providerPostalCode = ""
            providerHasMobileService = false
            providerMinPrice = 0
            providerServices = []

            providerCompanyName = ""
            providerTeamSize = 1
            providerYearsOfExperience = 0
            providerLogoUrl = nil
            providerBannerUrl = nil
            providerEmail = user.email
            providerOpeningHours = ""
        }
    }

    // MARK: Validation
    var validationErrors: [String] {
        var errors: [String] = []
        if phone.trimmed.isEmpty { errors.append("Le téléphone est requis.") }

        switch user.role {
        case .customer:
            if customerFirstName.trimmed.isEmpty { errors.append("Prénom requis.") }
            if customerLastName.trimmed.isEmpty { errors.append("Nom requis.") }
            if customerVehicleType == nil { errors.append("Type de véhicule requis.") }

        case .company:
            if companyLegalName.trimmed.isEmpty { errors.append("Raison sociale requise.") }
            if companyTypeId.trimmed.isEmpty { errors.append("Type d’entreprise requis.") }

        case .provider:
            if providerDisplayName.trimmed.isEmpty { errors.append("Nom public requis.") }
            if providerBaseCity.trimmed.isEmpty { errors.append("Ville requise.") }
            if providerPostalCode.trimmed.isEmpty { errors.append("Code postal requis.") }
            if providerMinPrice <= 0 { errors.append("Prix minimum requis (> 0).") }
            if vatNumber.trimmed.isEmpty { errors.append("Numéro de TVA requis pour activer les paiements.") }
        }
        return errors
    }

    var canSave: Bool { validationErrors.isEmpty && !isUploadingLogo && !isUploadingBanner && !isGeocoding }

    // MARK: Uploads
    func uploadProviderLogo() async {
        guard let data = selectedLogoData else { return }
        isUploadingLogo = true
        defer { isUploadingLogo = false }
        let res = await engine.mediaService.uploadFile(data: data, fileName: "logo.jpg", mimeType: "image/jpeg")
        switch res {
        case .success(let attachment):
            providerLogoUrl = attachment.url
            selectedLogoData = nil
        case .failure(let err):
            errorText = err.localizedDescription
        }
    }

    func uploadProviderBanner() async {
        guard let data = selectedBannerData else { return }
        isUploadingBanner = true
        defer { isUploadingBanner = false }
        let res = await engine.mediaService.uploadFile(data: data, fileName: "banner.jpg", mimeType: "image/jpeg")
        switch res {
        case .success(let attachment):
            providerBannerUrl = attachment.url
            selectedBannerData = nil
        case .failure(let err):
            errorText = err.localizedDescription
        }
    }

    // MARK: Geocoding
    private func geocodeIfNeeded() async {
        let city = providerBaseCity.trimmed
        let postal = providerPostalCode.trimmed
        guard !city.isEmpty || !postal.isEmpty else { return }

        isGeocoding = true
        defer { isGeocoding = false }

        let query = [city, postal].filter { !$0.isEmpty }.joined(separator: " ")
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(query)
            if let loc = placemarks.first?.location {
                geoLat = loc.coordinate.latitude
                geoLng = loc.coordinate.longitude
            }
        } catch {
            // silencieux: on garde lat/lng vides si géocodage échoue
        }
    }

    // MARK: Payloads
    private func buildProviderPayload() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["display_name"] = providerDisplayName.trimmed
        dict["company_name"] = providerCompanyName.nilIfEmpty
        dict["bio"] = providerBio.nilIfEmpty
        dict["base_city"] = providerBaseCity.nilIfEmpty
        dict["postal_code"] = providerPostalCode.nilIfEmpty
        dict["has_mobile_service"] = providerHasMobileService
        dict["min_price"] = providerMinPrice
        dict["services"] = providerServices.isEmpty ? [] : providerServices
        dict["team_size"] = providerTeamSize
        dict["years_of_experience"] = providerYearsOfExperience
        dict["logo_url"] = providerLogoUrl
        dict["banner_url"] = providerBannerUrl
        dict["phone"] = phone.nilIfEmpty
        dict["email"] = providerEmail.nilIfEmpty
        dict["opening_hours"] = providerOpeningHours.nilIfEmpty
        // Note: transport_price_per_km n'est plus utilisé - les frais sont fixes (zones avec plafond 20€)
        // dict["transport_price_per_km"] = providerTransportPricePerKm
        dict["transport_enabled"] = providerTransportEnabled
        if let lat = geoLat { dict["lat"] = lat }
        if let lng = geoLng { dict["lng"] = lng }
        return dict
    }

    // MARK: Save
    func save() async -> Bool {
        let errors = validationErrors
        guard errors.isEmpty else {
            toast = ToastState(message: errors.first ?? "Formulaire invalide.", kind: .error)
            return false
        }

        isSaving = true
        defer { isSaving = false }

        switch user.role {
        case .provider:
            await geocodeIfNeeded()
            let payload = buildProviderPayload()
            let response = await engine.detailerService.updateMyProfile(data: payload)
            switch response {
            case .success:
                toast = ToastState(message: "Profil prestataire mis à jour ✅", kind: .success)
                return true
            case .failure(let error):
                errorText = error.localizedDescription
                return false
            }

        case .customer, .company:
            let payload = buildPayloadForNonProvider()
            let response = await engine.userService.updateProfile(data: payload)
            switch response {
            case .success(let updatedUser):
                StorageManager.shared.saveUser(updatedUser)
                toast = ToastState(message: "Profil mis à jour ✅", kind: .success)
                return true
            case .failure(let error):
                errorText = error.localizedDescription
                return false
            }
        }
    }

    // Payload client/entreprise
    private func buildPayloadForNonProvider() -> [String: Any] {
        var payload: [String: Any] = [:]

        payload["phone"] = phone.nilIfEmpty
        payload["vatNumber"] = vatNumber.nilIfEmpty

        switch user.role {
        case .customer:
            var customerDict: [String: Any] = [:]
            customerDict["firstName"] = customerFirstName.trimmed
            customerDict["lastName"] = customerLastName.trimmed
            if let address = customerAddress.nilIfEmpty { customerDict["defaultAddress"] = address }
            if let vehicleType = customerVehicleType { customerDict["vehicleType"] = vehicleType.rawValue }
            payload["customerProfile"] = customerDict

        case .company:
            var companyDict: [String: Any] = [:]
            companyDict["legalName"] = companyLegalName.trimmed
            companyDict["companyTypeId"] = companyTypeId.trimmed
            if let city = companyCity.nilIfEmpty { companyDict["city"] = city }
            if let postal = companyPostalCode.nilIfEmpty { companyDict["postalCode"] = postal }
            if let contact = companyContactName.nilIfEmpty { companyDict["contactName"] = contact }
            payload["companyProfile"] = companyDict

        case .provider:
            break
        }

        return payload
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var nilIfEmpty: String? {
        let ver = trimmed
        return ver.isEmpty ? nil : ver
    }
}

