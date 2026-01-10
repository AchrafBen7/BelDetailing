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
        VStack(alignment: .leading, spacing: 16) {
            Text(R.string.localizable.bookingNotes())
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            Text(notes.isEmpty
                 ? R.string.localizable.bookingNotesEmpty()
                 : notes
            )
            .foregroundColor(notes.isEmpty ? .gray : .black)
            .font(.system(size: 15))
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}
