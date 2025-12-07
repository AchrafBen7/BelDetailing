import SwiftUI
import RswiftResources

struct SignupFormView: View {
    let role: UserRole
    let onBack: () -> Void
    let onSuccess: (String) -> Void
    let onLogin: () -> Void

    @StateObject private var vm: SignupViewModel

    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var vatNumber = ""
    @State private var password = ""

    @State private var isLoading = false   // 🔥 NEW anti double-clic

    // MARK: - INIT
    init(role: UserRole, engine: Engine, onBack: @escaping () -> Void,
         onSuccess: @escaping (String) -> Void, onLogin: @escaping () -> Void) {

        self.role = role
        self.onBack = onBack
        self.onSuccess = onSuccess
        self.onLogin = onLogin

        _vm = StateObject(wrappedValue: SignupViewModel(engine: engine, initialRole: role))
    }

    // MARK: - VALIDATION
    var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    var isFullNameValid: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var isPhoneValid: Bool {
        phone.count >= 8
    }

    var isVatValid: Bool {
        if role == .customer { return true }
        return vatNumber.count >= 8
    }

    var isFormValid: Bool {
        isEmailValid && isPasswordValid && isFullNameValid && isPhoneValid && isVatValid
    }

    // MARK: - BODY
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // === BACK BUTTON ===
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text(R.string.localizable.commonBack())
                            .font(.system(size: 17))
                    }
                    .foregroundColor(.gray)
                    .frame(height: 44, alignment: .leading)
                }
                .padding(.top, 8)

                // === TITLE ===
                Text(R.string.localizable.signupCreateAccountTitle())
                    .font(.system(size: 44, weight: .heavy))

                Text(R.string.localizable.signupCreateAccountSubtitle())
                    .font(.system(size: 17))
                    .foregroundColor(.gray)

                // === FIELDS ===
                VStack(spacing: 18) {
                    BDInputField(
                        title: R.string.localizable.signupFullNameLabel(),
                        placeholder: R.string.localizable.signupFullNamePlaceholder(),
                        text: $fullName,
                        keyboard: .default,
                        isSecure: false,
                        icon: "person",
                        showError: !isFullNameValid && !fullName.isEmpty,
                        errorText: R.string.localizable.signupFullNameError()
                    )

                    BDInputField(
                        title: R.string.localizable.emailLoginEmailLabel(),
                        placeholder: R.string.localizable.emailLoginEmailPlaceholder(),
                        text: $email,
                        keyboard: .emailAddress,
                        icon: "envelope",
                        showError: !email.isValidEmail && !email.isEmpty,
                        errorText: R.string.localizable.bookingInvalidEmail()
                    )
                    // 📱 Téléphone
                    BDInputField(
                        title: R.string.localizable.signupPhoneLabel(),
                        placeholder: R.string.localizable.signupPhonePlaceholder(),
                        text: $phone,
                        keyboard: .phonePad,
                        isSecure: false,
                        icon: "phone",
                        showError: !isPhoneValid && !phone.isEmpty,
                        errorText: R.string.localizable.signupPhoneInvalid()
                    )

                    // 🧾 TVA (pour company / provider)
                    if role == .company || role == .provider {
                        BDInputField(
                            title: R.string.localizable.signupVatLabel(),
                            placeholder: R.string.localizable.signupVatPlaceholder(),
                            text: $vatNumber,
                            keyboard: .default,
                            isSecure: false,
                            icon: "doc.text",
                            showError: !isVatValid && !vatNumber.isEmpty,
                            errorText: R.string.localizable.signupVatInvalid()
                        )
                    }

                    // 🔐 Mot de passe
                    BDInputField(
                        title: R.string.localizable.signupPasswordLabel(),
                        placeholder: R.string.localizable.signupPasswordPlaceholder(),
                        text: $password,
                        keyboard: .default,
                        isSecure: true,
                        icon: "lock",
                        showError: !isPasswordValid && !password.isEmpty,
                        errorText: R.string.localizable.signupPasswordTooShort()
                    )
                }

                // === CTA ===
                Button {
                    if isLoading { return }
                    isLoading = true

                    Task {
                        if let returnedEmail = await vm.registerUser(
                            email: email,
                            password: password,
                            phone: phone,
                            vatNumber: (role == .company || role == .provider) ? vatNumber : nil
                        ) {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            await MainActor.run { onSuccess(returnedEmail) }  // 🔥 navigation OK
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }

                        isLoading = false
                    }
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(R.string.localizable.signupCreateAccount())
                                .font(.system(size: 17, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isFormValid ? Color.black : Color.gray.opacity(0.3))
                    )
                    .foregroundColor(.white)
                }
                .disabled(!isFormValid || isLoading)
                .opacity(isFormValid ? 1 : 0.5)

                // === LOGIN LINK ===
                HStack(spacing: 6) {
                    Text(R.string.localizable.signupAlreadyAccount())
                        .foregroundColor(.gray)
                    Button(action: onLogin) {
                        Text(R.string.localizable.signupLoginAction())
                            .underline()
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            if vm.selectedRole == nil {
                vm.selectedRole = role
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
