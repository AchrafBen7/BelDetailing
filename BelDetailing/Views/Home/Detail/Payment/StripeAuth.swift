//
//  StripeAuth.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/12/2025.
//

import UIKit
import StripePaymentSheet

final class StripeAuthContext: NSObject, STPAuthenticationContext {

    let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
    }

    func authenticationPresentingViewController() -> UIViewController {
        return viewController
    }
}

