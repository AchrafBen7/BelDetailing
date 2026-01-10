//
//  SupportViewModel.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import Foundation
import UIKit
import Combine
@MainActor
final class SupportViewModel: ObservableObject {
    @Published var subject: String = ""
    @Published var message: String = ""
    @Published var isSending = false
    
    let engine: Engine
    
    let supportEmail = LegalInfo.supportEmail
    let supportPhone: String? = LegalInfo.supportPhone
    
    init(engine: Engine) {
        self.engine = engine
    }
    
    var canSend: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func openEmail() {
        if let url = URL(string: "mailto:\(supportEmail)") {
            UIApplication.shared.open(url)
        }
    }
    
    func callPhone() {
        guard let phone = supportPhone else { return }
        let cleanPhone = phone.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel:\(cleanPhone)") {
            UIApplication.shared.open(url)
        }
    }
}

