import SwiftUI

extension BookingStep2View {
    
    func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .padding(.vertical, 14)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
    }
}
