import Foundation
import RevenueCat

final class PurchasesDelegateHandler: NSObject, PurchasesDelegate {
    static let shared = PurchasesDelegateHandler()

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            PlantPalProManager.shared.updateProStatus(from: customerInfo)
        }
    }
}
