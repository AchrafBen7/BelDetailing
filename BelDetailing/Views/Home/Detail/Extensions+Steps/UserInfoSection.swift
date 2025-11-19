//
//  UserInfoSection.swift
//  BelDetailing
//
//  Created by Achraf Benali on 19/11/2025.
//
//  UserInfoSection.swift

import SwiftUI
import RswiftResources

extension BookingStep2View {

    var userInfoSection: some View {

        VStack(alignment: .leading, spacing: 22) {

            // TITLE
            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                Text(R.string.localizable.bookingYourInformation())
                    .font(.system(size: 22, weight: .bold))
            }

            // FULL NAME
            inputField(
                title: R.string.localizable.bookingFullName(),
                text: $fullName,
                placeholder: R.string.localizable.bookingFullNamePlaceholder()
            )

            // PHONE
            inputField(
                title: R.string.localizable.bookingPhone(),
                text: $phone,
                placeholder: R.string.localizable.bookingPhonePlaceholder()
            )

            // EMAIL
            inputField(
                title: R.string.localizable.bookingEmail(),
                text: $email,
                placeholder: R.string.localizable.bookingEmailPlaceholder()
            )

            // NOTES
            VStack(alignment: .leading, spacing: 6) {
                Text(R.string.localizable.bookingNotes())
                    .font(.system(size: 16, weight: .semibold))

                TextField(
                    R.string.localizable.bookingNotesPlaceholder(),
                    text: $notes
                )
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(14)
            }
        }
    }
}
