//
//  MessageBubble.swift
//  BelDetailing
//
//  Created on 01/01/2026.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(isFromCurrentUser ? .black : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        isFromCurrentUser
                            ? Color.white
                            : Color.white.opacity(0.2)
                    )
                    .cornerRadius(18)
                
                if let createdAt = message.createdAt,
                   let date = DateFormatters.iso8601(createdAt) {
                    Text(date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 4)
                }
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
}
