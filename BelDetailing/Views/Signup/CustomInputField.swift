import SwiftUI

struct CustomInputField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    let errorText: String
    let showError: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(showError ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .animation(.easeInOut(duration: 0.15), value: showError)
    }
}
