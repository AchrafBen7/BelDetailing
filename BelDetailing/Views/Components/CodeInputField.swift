//
//  CodeInputField.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct CodeInputField: View {
    @Binding var code: String
    let numberOfDigits: Int
    var onCodeComplete: (() -> Void)? = nil
    
    @FocusState private var focusedIndex: Int?
    @State private var digits: [String] = []
    
    init(code: Binding<String>, numberOfDigits: Int = 6, onCodeComplete: (() -> Void)? = nil) {
        self._code = code
        self.numberOfDigits = numberOfDigits
        self.onCodeComplete = onCodeComplete
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<numberOfDigits, id: \.self) { index in
                digitField(at: index)
            }
        }
        .onAppear {
            initializeDigits()
        }
    }
    
    private func digitField(at index: Int) -> some View {
        TextField("", text: digitBinding(for: index))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 50, height: 60)
            .background(digitBackground(for: index))
            .focused($focusedIndex, equals: index)
            .onChange(of: code) { oldValue, newValue in
                handleCodeChange(oldValue: oldValue, newValue: newValue)
            }
    }
    
    private func digitBinding(for index: Int) -> Binding<String> {
        Binding(
            get: {
                guard index < digits.count else { return "" }
                return digits[index]
            },
            set: { newValue in
                handleDigitChange(at: index, newValue: newValue)
            }
        )
    }
    
    private func handleDigitChange(at index: Int, newValue: String) {
        let filtered = newValue.filter { $0.isNumber }.prefix(1)
        
        // Mettre à jour le tableau
        if index < digits.count {
            digits[index] = String(filtered)
        } else {
            digits.append(String(filtered))
        }
        
        // Si un caractère a été saisi, passer au champ suivant
        if !filtered.isEmpty && index < numberOfDigits - 1 {
            focusedIndex = index + 1
        }
        
        // Mettre à jour le code complet
        updateCode()
    }
    
    private func digitBackground(for index: Int) -> some View {
        let isFocused = focusedIndex == index
        let hasValue = index < digits.count && !digits[index].isEmpty
        let backgroundColor = (isFocused || hasValue) ? Color.gray.opacity(0.4) : Color.gray.opacity(0.25)
        let strokeColor = isFocused ? Color.orange : Color.clear
        
        return RoundedRectangle(cornerRadius: 12)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 2)
            )
    }
    
    private func handleCodeChange(oldValue: String, newValue: String) {
        // Si le code est modifié de l'extérieur, mettre à jour les digits
        if newValue.count == numberOfDigits && newValue != oldValue {
            digits = Array(newValue).map { String($0) }
        }
    }
    
    private func initializeDigits() {
        // Initialiser le tableau avec des chaînes vides
        digits = Array(repeating: "", count: numberOfDigits)
        // Si le code existe déjà, le remplir
        if !code.isEmpty && code.count == numberOfDigits {
            digits = Array(code).map { String($0) }
        }
    }
    
    private func updateCode() {
        let newCode = digits.joined()
        code = newCode
        
        // Si le code est complet, appeler le callback
        if newCode.count == numberOfDigits {
            onCodeComplete?()
        }
    }
}
