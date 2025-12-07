//
//  UiApplication.swift
//  BelDetailing
//
//  Created by Achraf Benali on 07/12/2025.
//

import UIKit

extension UIApplication {

    /// Retourne le viewController actuellement visible pour présenter Stripe
    static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC: UIViewController?
        if let base = base {
            baseVC = base
        } else {
            baseVC = UIApplication.shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?
                .rootViewController
        }

   
        if let nav = baseVC as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

   
        if let tab = baseVC as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }

    
        if let presented = baseVC?.presentedViewController {
            return topViewController(base: presented)
        }

        return baseVC
    }
}
