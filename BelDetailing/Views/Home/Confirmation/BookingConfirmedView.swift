//
//  BookingConfirmedView.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//

import SwiftUI
import RswiftResources

struct BookingConfirmedView: View {

    let engine: Engine

    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @Binding var tabSelection: MainTabView.Tab   // 👈 pour rediriger
    @Environment(\.presentationMode) var presentationMode


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
                Text(R.string.localizable.bookingConfirmedTitle())
                    .font(.system(size: 26, weight: .bold))

                // SUBTITLE
                Text(R.string.localizable.bookingConfirmedSubtitle())
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                // GO TO BOOKINGS
                Button {
                    // 1. Change l’onglet
                    tabSelection = .bookings

                    // 2. Ferme TOUT le flow (Step3, Step2, Step1)
                    presentationMode.wrappedValue.dismiss()
                    presentationMode.wrappedValue.dismiss()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text(R.string.localizable.bookingConfirmedButton())
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(40)
                        .padding(.horizontal, 24)
                }

                Spacer().frame(height: 30)
            }
        }
        .onAppear {
            tabBarVisibility.isHidden = true

            // Auto-redirection après 2 secondes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                tabSelection = .bookings
            }
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
        }
    }
}
