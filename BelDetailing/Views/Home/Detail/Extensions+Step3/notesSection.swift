//
//  notesSection.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//
import SwiftUI
import RswiftResources

extension BookingStep3View {

    var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(R.string.localizable.bookingNotes())
                .font(.system(size: 22, weight: .bold))

            Text(notes.isEmpty
                 ? R.string.localizable.bookingNotesEmpty()
                 : notes
            )
            .foregroundColor(.gray)
            .padding(.vertical, 14)
            .padding(.horizontal, cardInset)   // 👈 IDENTIQUE
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(20)
        }
    }
}
