import Foundation
import StoreKit

/// In-app purchase configuration. Keep in sync with App Store Connect and `TestStoreKit.storekit`.
enum PremiumIAP {
    static let productID = "wordgen_premium"

    static var allProductIDs: [String] { [productID] }

    /// Loads the premium product from the App Store (or StoreKit Testing in DEBUG).
    static func loadProduct() async throws -> Product {
        let products = try await Product.products(for: allProductIDs)
        guard let product = products.first else {
            throw PremiumIAPError.productUnavailable
        }
        return product
    }

    /// Returns a verified transaction or throws (do not unlock on failure).
    static func verifiedTransaction(from result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified(_, let error):
            throw error
        }
    }

    /// Whether the user has an active **verified** entitlement for the premium product.
    static func hasVerifiedEntitlement() async -> Bool {
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else { continue }
            if transaction.productID == productID {
                return true
            }
        }
        return false
    }

    enum PremiumIAPError: Error {
        case productUnavailable
    }
}
