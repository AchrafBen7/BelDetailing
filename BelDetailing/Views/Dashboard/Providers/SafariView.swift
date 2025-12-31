//
//  SafariView.swift
//  BelDetailing
//
//  Created on 31/12/2025.
//

import SwiftUI
import SafariServices

public struct SafariView: UIViewControllerRepresentable, Identifiable {
    public let id = UUID()
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.dismissButtonStyle = .close
        return vc
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
