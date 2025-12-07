
import Foundation

enum PaymentResult {
    case success
    case failure(String)   // message d’erreur
    case canceled
}
