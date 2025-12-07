//
//  VerifyEmailView.swift
//  BelDetailing
//

import SwiftUI
import RswiftResources

struct VerifyEmailView: View {
    let email: String
    let onBackToLogin: () -> Void
    let onResendEmail: () async -> Void

    @State private var secondsLeft = 60

    var body: some View {
        VStack(spacing: 28) {

            // Icone
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "envelope.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 36, height: 36)
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                }
                .frame(width: 120, height: 120)
            }
            .padding(.top, 40)

            // Titre + texte
            VStack(spacing: 8) {
                R.string.localizable.verifyEmailTitle()
                    .textView(style: .sectionTitle)

                R.string.localizable.verifyEmailSubtitle1()
                    .textView(style: .subtitle)


                Text(email)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                R.string.localizable.verifyEmailSubtitle2()
                    .textView(style: .subtitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

            }
            .padding(.horizontal, 20)

            // Étapes
            VStack(alignment: .leading, spacing: 18) {
                verifyStep(
                    number: 1,
                    title: Text(R.string.localizable.verifyEmailStep1Title()),
                    subtitle: Text(R.string.localizable.verifyEmailStep1Subtitle())
                )

                verifyStep(
                    number: 2,
                    title: Text(R.string.localizable.verifyEmailStep2Title()),
                    subtitle: Text(R.string.localizable.verifyEmailStep2Subtitle())
                )

                verifyStep(
                    number: 3,
                    title: Text(R.string.localizable.verifyEmailStep3Title()),
                    subtitle: Text(R.string.localizable.verifyEmailStep3Subtitle())
                )
            }

            .padding(20)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            .padding(.horizontal, 20)

            // RESEND BUTTON
            // RESEND BUTTON
            Button {
                Task {
                    guard secondsLeft == 0 else { return }
                    await onResendEmail()
                    resetTimer()
                }
            } label: {
                let resendTitle: String = {
                    if secondsLeft > 0 {
                        // ⚠️ on passe une String, pas un Int
                        return R.string.localizable.verifyEmailResendCountdown("\(secondsLeft)")
                    } else {
                        return R.string.localizable.verifyEmailResend()
                    }
                }()

                Text(resendTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(secondsLeft > 0 ? 0.4 : 1))
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(secondsLeft > 0)
            .padding(.horizontal, 20)

            // Retour à la connexion
            Button(action: onBackToLogin) {
                Text(R.string.localizable.verifyEmailBackToLogin())
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .underline()
            }

            Spacer()
        }
        .onAppear { startTimer() }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func verifyStep(number: Int, title: Text, subtitle: Text) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)
                )

            VStack(alignment: .leading, spacing: 4) {
                title
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)

                subtitle
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if secondsLeft > 0 {
                secondsLeft -= 1
            } else {
                timer.invalidate()
            }
        }
    }

    private func resetTimer() {
        secondsLeft = 60
        startTimer()
    }
}
