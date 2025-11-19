//
//  BookingStep3View.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources
struct BookingStep3View: View {
    let service: Service
    let detailer: Detailer
    let date: Date
    let time: String
    let engine: Engine
    let fullName: String
    let phone: String
    let email: String
    let notes: String

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @EnvironmentObject var mainTabSelection: MainTabSelection

    @State var goToConfirmation = false
    @State var selectedPayment: PaymentMethod = .card
    @State var promoCode: String = ""
    let cardInset: CGFloat = 20

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // HEADER + SCROLL
            VStack(spacing: 0) {

                // === FIXED BACK BUTTON ===
                CustomBackButton {
                    dismiss()
                }

                // === MAIN CONTENT ===
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        Spacer().frame(height: 20)

                        recapSection
                        paymentSection
                        promoCodeSection
                        notesSection
                        priceBreakdownSection
                        termsSection

                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        // === FIXED BOTTOM BUTTON ===
        .overlay(alignment: .bottom) {
            VStack {
                confirmButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .background(
                Color(.systemGroupedBackground)
                    .opacity(0.98)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        // === NAVIGATION ===
        .background(
            NavigationLink(
                destination: BookingConfirmedView(
                    engine: engine,
                    tabSelection: $mainTabSelection.currentTab
                )
                .environmentObject(tabBarVisibility),
                isActive: $goToConfirmation
            ) { EmptyView() }
        )
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { tabBarVisibility.isHidden = true }
        .onDisappear { tabBarVisibility.isHidden = false }
    }
}
