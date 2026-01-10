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
    var isDarkStyle: Bool = false // 🔥 NEW: pour fonds sombres

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isDarkStyle ? .white.opacity(0.9) : .black)

            HStack(spacing: 14) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundColor(isDarkStyle ? .white.opacity(0.6) : .gray)
                        .frame(width: 22)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .foregroundColor(isDarkStyle ? .white : .black)
                        .font(.system(size: 17))
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .foregroundColor(isDarkStyle ? .white : .black)
                        .font(.system(size: 17))
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .background(
                Group {
                    if isDarkStyle {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(showError ? Color.red.opacity(0.6) : Color.white.opacity(0.2), lineWidth: 1.5)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(showError ? Color.red : Color.gray.opacity(0.3), lineWidth: 1.5)
                    }
                }
            )

            // 🔴 Ligne d'erreur optionnelle
            if showError, let errorText {
                Text(errorText)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: showError)
    }
}
