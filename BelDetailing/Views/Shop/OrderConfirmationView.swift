//
//  OrderConfirmationView.swift
//  BelDetailing
//
//  Created on 30/12/2025.
//

import SwiftUI
import RswiftResources

struct OrderConfirmationView: View {
    let order: Order
    let onDismiss: () -> Void
    
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 26) {
                Spacer().frame(height: 60)
                
                // CHECK ICON
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.green)
                
                // TITLE
                Text(R.string.localizable.orderConfirmationTitle())
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)
                
                // SUBTITLE
                Text(R.string.localizable.orderConfirmationSubtitle())
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // ORDER NUMBER
                VStack(spacing: 8) {
                    Text(R.string.localizable.orderConfirmationOrderNumber())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(order.id)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
                
                Spacer()
                
                // CONTINUE SHOPPING BUTTON
                Button {
                    onDismiss()
                    dismiss()
                } label: {
                    Text(R.string.localizable.orderConfirmationButton())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 24)
                }
                
                Spacer().frame(height: 30)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            tabBarVisibility.isHidden = true
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
    }
}

