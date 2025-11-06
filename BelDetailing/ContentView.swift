//
//  ContentView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 04/11/2025.
//

import SwiftUI
import RswiftResources

struct ContentView: View {
    var body: some View {
        VStack {
            Text("test")
                .foregroundStyle(Color(R.color.secondaryOrange))
                .font(.custom(R.font.avenirNextLTProRegular, size: 18))
            Text(R.string.localizable.textSampleNQuantity(1))
                .foregroundStyle(Color(R.color.primaryText))
                .font(.custom(R.font.avenirNextLTProBold, size: 22))
            Text(R.string.localizable.textSampleNQuantity(2))
                .foregroundStyle(Color(R.color.secondaryRed))
                .font(.custom(R.font.avenirNextLTProIt, size: 30))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
