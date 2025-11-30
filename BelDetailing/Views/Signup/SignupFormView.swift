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
                    CustomInputField(
                        icon: "person",
                        title: R.string.localizable.signupFullNameLabel(),
                        placeholder: R.string.localizable.signupFullNamePlaceholder(),
                        text: $fullName,
                        errorText: "Please enter your full name",
                        showError: !isFullNameValid && !fullName.isEmpty
                    )

                    CustomInputField(
                        icon: "envelope",
                        title: R.string.localizable.signupEmailLabel(),
                        placeholder: R.string.localizable.signupEmailPlaceholder(),
                        text: $email,
                        keyboardType: .emailAddress,
                        errorText: "Enter a valid email",
                        showError: !isEmailValid && !email.isEmpty
                    )

                    CustomInputField(
                        icon: "phone",
                        title: R.string.localizable.signupPhoneLabel(),
                        placeholder: R.string.localizable.signupPhonePlaceholder(),
                        text: $phone,
                        keyboardType: .phonePad,
                        errorText: "Invalid phone number",
                        showError: !isPhoneValid && !phone.isEmpty
                    )

                    if role == .company || role == .provider {
                        CustomInputField(
                            icon: "doc.text",
                            title: R.string.localizable.signupVatLabel(),
                            placeholder: R.string.localizable.signupVatPlaceholder(),
                            text: $vatNumber,
                            errorText: "VAT number required",
                            showError: !isVatValid && !vatNumber.isEmpty
                        )
                    }

                    CustomInputField(
                        icon: "lock",
                        title: R.string.localizable.signupPasswordLabel(),
                        placeholder: R.string.localizable.signupPasswordPlaceholder(),
                        text: $password,
                        isSecure: true,
                        errorText: "Min. 6 characters",
                        showError: !isPasswordValid && !password.isEmpty
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
