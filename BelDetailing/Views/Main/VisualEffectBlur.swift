//
//  VisualEffectBlur.swift
//  BelDetailing
//
//  Created by Achraf Benali on 21/12/2025.
//

import SwiftUI

struct VisualEffectBlur: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
