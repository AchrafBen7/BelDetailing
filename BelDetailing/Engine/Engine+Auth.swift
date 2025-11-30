//  Engine+Auth.swift
//  BelDetailing

import Foundation

extension Engine {

    @MainActor
    func logout() async {
        _ = await userService.logout()   // fait déjà : clear tokens, clear user, reset headers
    }
}
