import Foundation
import RevenueCat

@MainActor
final class PlantPalProManager: ObservableObject {
    static let shared = PlantPalProManager()

    static let apiKey = "appl_REPLACE_WITH_REVENUECAT_API_KEY"
    static let entitlementID = "pro"
    static let productID = "com.chadnewbry.plantpal.pro"

    @Published private(set) var isPro: Bool = false
    @Published private(set) var isLoading: Bool = false

    private init() {}

    func configure() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Self.apiKey)
        Purchases.shared.delegate = PurchasesDelegateHandler.shared

        Task {
            await checkProStatus()
        }
    }

    func checkProStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateProStatus(from: customerInfo)
        } catch {
            print("PlantPalProManager: Failed to fetch customer info: \(error)")
        }
    }

    func purchasePro() async throws {
        isLoading = true
        defer { isLoading = false }

        let offerings = try await Purchases.shared.offerings()
        guard let package = offerings.current?.lifetime else {
            throw PurchaseError.noProductFound
        }

        let result = try await Purchases.shared.purchase(package: package)
        updateProStatus(from: result.customerInfo)

        if !isPro {
            throw PurchaseError.purchaseFailed
        }
    }

    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }

        let customerInfo = try await Purchases.shared.restorePurchases()
        updateProStatus(from: customerInfo)
    }

    func updateProStatus(from customerInfo: CustomerInfo) {
        isPro = customerInfo.entitlements[Self.entitlementID]?.isActive == true
    }
}

enum PurchaseError: LocalizedError {
    case noProductFound
    case purchaseFailed

    var errorDescription: String? {
        switch self {
        case .noProductFound:
            return "Unable to find PlantPal Pro. Please try again later."
        case .purchaseFailed:
            return "Purchase could not be completed. Please try again."
        }
    }
}
