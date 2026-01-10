import SwiftUI
import RswiftResources

// swiftlint:disable type_body_length
struct SignupFormView: View {
    let role: UserRole
    let onBack: () -> Void
    let onSuccess: (String) -> Void
    let onLogin: () -> Void
    let engine: Engine

    @StateObject private var vm: SignupViewModel

    // Common fields
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var vatNumber = ""
    @State private var password = ""

    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showAccountExistsAlert = false

    // Customer specific
    @State private var customerFirstName = ""
    @State private var customerLastName = ""
    @State private var customerVehicleType: VehicleType?
    @State private var customerAddress: String = ""
    
    // Customer signup steps (1 = véhicule, 2 = autres champs)
    @State private var customerSignupStep: Int = 1

    // Company specific
    @State private var companyLegalName = ""
    @State private var companyTypeId: CompanyType?
    @State private var companyCity: String = ""
    @State private var companyPostalCode: String = ""
    @State private var companyContactName: String = ""

    // Provider specific
    @State private var providerDisplayName = ""
    @State private var providerBaseCity = ""
    @State private var providerPostalCode = ""
    @State private var providerMinPrice: Double = 0
    @State private var providerHasMobileService: Bool = false
    @State private var providerCompanyName: String = ""
    @State private var providerBio: String = ""
    
    // VAT Verification state
    @State private var vatLookupResult: VatLookupResponse? = nil
    @State private var isVerifyingVAT = false
    @State private var vatVerificationError: String? = nil

    // MARK: - Init
    init(role: UserRole, engine: Engine, onBack: @escaping () -> Void,
         onSuccess: @escaping (String) -> Void, onLogin: @escaping () -> Void) {
        self.role = role
        self.engine = engine
        self.onBack = onBack
        self.onSuccess = onSuccess
        self.onLogin = onLogin
        _vm = StateObject(wrappedValue: SignupViewModel(engine: engine, initialRole: role))
    }

    // MARK: - Validation
    var isEmailValid: Bool { email.contains("@") && email.contains(".") }
    var isPasswordValid: Bool { password.count >= 6 }
    var isFullNameValid: Bool { !fullName.trimmingCharacters(in: .whitespaces).isEmpty }
    var isPhoneValid: Bool { phone.count >= 8 }
    var isVatValid: Bool { role == .customer ? true : vatNumber.count >= 8 }

    var isCustomerFormValid: Bool {
        isEmailValid && isPasswordValid && isPhoneValid &&
        !customerFirstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !customerLastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        customerVehicleType != nil
    }

    var isCompanyFormValid: Bool {
        isEmailValid && isPasswordValid && isPhoneValid && isVatValid &&
        !companyLegalName.trimmingCharacters(in: .whitespaces).isEmpty &&
        companyTypeId != nil
    }

    var isProviderFormValid: Bool {
        isEmailValid && isPasswordValid && isPhoneValid && isVatValid &&
        !providerDisplayName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !providerBaseCity.trimmingCharacters(in: .whitespaces).isEmpty &&
        !providerPostalCode.trimmingCharacters(in: .whitespaces).isEmpty &&
        providerMinPrice > 0
    }

    var isFormValid: Bool {
        switch role {
        case .customer: return isCustomerFormValid
        case .company: return isCompanyFormValid
        case .provider: return isProviderFormValid
        }
    }

    // MARK: - Body
    var body: some View {
        Group {
            // Pour customer : 2 étapes
            if role == .customer {
                customerSignupFlow
            } else {
                // Pour provider/company : formulaire unique
                standardSignupFlow
            }
        }
        .onAppear {
            if vm.selectedRole == nil {
                vm.selectedRole = role
            }
        }
        .alert("Compte déjà existant", isPresented: $showAccountExistsAlert) {
            Button("OK", role: .cancel) {
                showAccountExistsAlert = false
            }
            Button("Aller à la connexion") {
                showAccountExistsAlert = false
                onLogin()
            }
        } message: {
            Text("Un compte avec cet email existe déjà.")
        }
        .alert("Erreur", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            if let msg = errorMessage {
                Text(msg)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Customer Signup Flow (2 étapes)
    
    private var customerSignupFlow: some View {
        Group {
            if customerSignupStep == 1 {
                // Étape 1 : Sélection du véhicule
                VehicleSelectionStepView(
                    selectedVehicleType: $customerVehicleType,
                    onContinue: {
                        withAnimation {
                            customerSignupStep = 2
                        }
                    },
                    onBack: onBack
                )
            } else {
                // Étape 2 : Autres champs
                CustomerSignupStep2View(
                    firstName: $customerFirstName,
                    lastName: $customerLastName,
                    address: $customerAddress,
                    email: $email,
                    phone: $phone,
                    password: $password,
                    vehicleType: customerVehicleType ?? .berline,
                    onBack: {
                        withAnimation {
                            customerSignupStep = 1
                        }
                    },
                    onSubmit: {
                        handleSignup()
                    },
                    onLogin: onLogin
                )
            }
        }
    }
    
    // MARK: - Standard Signup Flow (provider/company)
    
    private var standardSignupFlow: some View {
        ZStack {
            backgroundImage

            VStack(spacing: 0) {
                topBackButton
                Spacer()
                scrollableContentCard
                Spacer()
            }
        }
        .onAppear {
            if vm.selectedRole == nil {
                vm.selectedRole = role
            }
        }
        .alert("Compte déjà existant", isPresented: $showAccountExistsAlert) {
            Button("OK", role: .cancel) {
                showAccountExistsAlert = false
            }
            Button("Aller à la connexion") {
                showAccountExistsAlert = false
                onLogin()
            }
        } message: {
            Text("Un compte avec cet email existe déjà.")
        }
        .alert("Erreur", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            if let msg = errorMessage {
                Text(msg)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Subviews
    private var backgroundImage: some View {
        GeometryReader { geometry in
            Image("launchImage")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(Color.black.opacity(0.65))
        }
        .ignoresSafeArea()
    }

    private var topBackButton: some View {
        HStack {
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
    }

    private var scrollableContentCard: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                    .padding(.bottom, 32)
                
                // Progress indicator pour provider/company
                if role == .provider || role == .company {
                    progressIndicator
                        .padding(.bottom, 32)
                }
                
                formFields
                ctaButton
                    .padding(.top, 32)
                loginLink
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .background(cardBackground)
        .padding(.horizontal, 20)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.black.opacity(0.3))
            )
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titleText)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Text(subtitleText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    private var titleText: String {
        switch role {
        case .provider: return "Devenir prestataire"
        case .company: return "Inscrivez votre entreprise"
        case .customer: return "Créer un compte"
        }
    }
    
    private var subtitleText: String {
        switch role {
        case .provider: return "Inscrivez votre entreprise sur BelDetail"
        case .company: return "Créez votre compte entreprise"
        case .customer: return "Renseignez vos informations pour créer un compte."
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(1...3, id: \.self) { step in
                Circle()
                    .fill(step == 1 ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("\(step)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(step == 1 ? .black : .white)
                    )
                
                if step < 3 {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var formFields: some View {
        VStack(spacing: 40) {
            // Pour provider/company : VAT en premier
            if role == .provider || role == .company {
                SignupVatVerificationSection(
                    role: role,
                    engine: engine,
                    vatNumber: $vatNumber,
                    vatLookupResult: $vatLookupResult,
                    isVerifyingVAT: $isVerifyingVAT,
                    vatVerificationError: $vatVerificationError,
                    companyLegalName: $companyLegalName,
                    companyCity: $companyCity,
                    companyPostalCode: $companyPostalCode,
                    providerBaseCity: $providerBaseCity,
                    providerPostalCode: $providerPostalCode,
                    providerCompanyName: $providerCompanyName
                )
                
                SignupCompanyInfoSection(
                    role: role,
                    companyLegalName: $companyLegalName,
                    companyTypeId: $companyTypeId,
                    companyCity: $companyCity,
                    companyPostalCode: $companyPostalCode,
                    companyContactName: $companyContactName,
                    providerDisplayName: $providerDisplayName,
                    providerCompanyName: $providerCompanyName
                )
                
                SignupContactSecuritySection(
                    email: $email,
                    phone: $phone,
                    password: $password,
                    isEmailValid: isEmailValid,
                    isPhoneValid: isPhoneValid,
                    isPasswordValid: isPasswordValid
                )
                
                if role == .provider {
                    SignupZonePricingSection(
                        providerBaseCity: $providerBaseCity,
                        providerPostalCode: $providerPostalCode,
                        providerMinPrice: $providerMinPrice,
                        providerHasMobileService: $providerHasMobileService
                    )
                    
                    SignupPresentationSection(
                        providerBio: $providerBio
                    )
                }
            } else {
                // Pour customer : ordre original
                personalInfoSection
                connectionSection
                contactSection
            }
        }
    }

    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "person.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Informations personnelles")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            roleSpecificFields
        }
    }

    @ViewBuilder
    private var roleSpecificFields: some View {
        switch role {
        case .customer:
            SignupCustomerFields(
                firstName: $customerFirstName,
                lastName: $customerLastName,
                vehicleType: $customerVehicleType,
                address: $customerAddress,
                isDarkStyle: true
            )
        case .company:
            SignupCompanyFields(
                legalName: $companyLegalName,
                companyTypeId: $companyTypeId,
                city: $companyCity,
                postalCode: $companyPostalCode,
                contactName: $companyContactName,
                isDarkStyle: true
            )
        case .provider:
            SignupProviderFields(
                displayName: $providerDisplayName,
                baseCity: $providerBaseCity,
                postalCode: $providerPostalCode,
                minPrice: $providerMinPrice,
                hasMobileService: $providerHasMobileService,
                companyName: $providerCompanyName,
                bio: $providerBio,
                isDarkStyle: true
            )
        }
    }

    private var connectionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text("Connexion")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 20) {
                BDInputField(
                    title: "Email",
                    placeholder: "nom@domaine.com",
                    text: $email,
                    keyboard: .emailAddress,
                    icon: "envelope",
                    showError: !email.isValidEmail && !email.isEmpty,
                    errorText: "Email invalide",
                    isDarkStyle: true
                )
                BDInputField(
                    title: "Mot de passe",
                    placeholder: "Votre mot de passe",
                    text: $password,
                    keyboard: .default,
                    isSecure: true,
                    icon: "lock",
                    showError: !isPasswordValid && !password.isEmpty,
                    errorText: "Mot de passe trop court",
                    isDarkStyle: true
                )
            }
        }
    }

    private var contactSection: some View {
        SignupContactSection(
            role: role,
            phone: $phone,
            vatNumber: $vatNumber,
            isPhoneValid: isPhoneValid,
            isVatValid: isVatValid,
            engine: engine,
            // Company bindings
            companyLegalName: $companyLegalName,
            companyCity: $companyCity,
            companyPostalCode: $companyPostalCode,
            // Provider bindings
            providerBaseCity: $providerBaseCity,
            providerPostalCode: $providerPostalCode,
            providerCompanyName: $providerCompanyName
        )
    }

    private var ctaButton: some View {
        Button {
            handleSignup()
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(role == .provider ? "Créer mon compte prestataire" : role == .company ? "Créer mon compte entreprise" : "Créer un compte")
                        .font(.system(size: 17, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .disabled(!isFormValid || isLoading)
        .opacity(isFormValid ? 1 : 0.5)
        .padding(.top, 8)
    }

    private var loginLink: some View {
        Button(action: onLogin) {
            HStack(spacing: 4) {
                Text("Vous avez déjà un compte ?")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                Text("Se connecter")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Actions
    private func handleSignup() {
        if isLoading { return }
        isLoading = true
        Task {
            let signupData = buildSignupData()
            do {
                let returnedEmail = try await vm.registerUser(data: signupData)
                print("🔍 [SIGNUP] Register returned email: '\(returnedEmail)'")
                
                // Utiliser l'email retourné, ou fallback sur l'email du formulaire
                let emailToUse = returnedEmail.isEmpty ? email : returnedEmail
                print("🔍 [SIGNUP] Using email for verification: '\(emailToUse)'")
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                await MainActor.run { 
                    onSuccess(emailToUse)
                }
            } catch {
                await MainActor.run {
                    if error.localizedDescription == "account_exists" {
                        showAccountExistsAlert = true
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
            isLoading = false
        }
    }


    private func buildSignupData() -> SignupData {
        SignupData(
            email: email,
            password: password,
            phone: phone,
            vatNumber: (role == .company || role == .provider) ? vatNumber : nil,
            customerFirstName: role == .customer ? customerFirstName : nil,
            customerLastName: role == .customer ? customerLastName : nil,
            customerVehicleType: role == .customer ? customerVehicleType : nil,
            customerAddress: role == .customer && !customerAddress.isEmpty ? customerAddress : nil,
            companyLegalName: role == .company ? companyLegalName : nil,
            companyTypeId: role == .company ? companyTypeId?.rawValue : nil,
            companyCity: role == .company && !companyCity.isEmpty ? companyCity : nil,
            companyPostalCode: role == .company && !companyPostalCode.isEmpty ? companyPostalCode : nil,
            companyContactName: role == .company && !companyContactName.isEmpty ? companyContactName : nil,
            providerDisplayName: role == .provider ? providerDisplayName : nil,
            providerBaseCity: role == .provider ? providerBaseCity : nil,
            providerPostalCode: role == .provider ? providerPostalCode : nil,
            providerMinPrice: role == .provider ? providerMinPrice : nil,
            providerHasMobileService: role == .provider ? providerHasMobileService : nil,
            providerCompanyName: role == .provider && !providerCompanyName.isEmpty ? providerCompanyName : nil,
            providerBio: role == .provider && !providerBio.isEmpty ? providerBio : nil
        )
    }
}

