import SwiftUI

struct BDInputField: View {

    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var icon: String? = nil
    var showError: Bool = false
    var errorText: String? = nil

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)

            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(showError ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
            )

            // 🔴 Ligne d’erreur optionnelle
            if showError, let errorText {
                Text(errorText)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: showError)
    }
}
