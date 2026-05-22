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
    /// Async — talks to StoreKit. Use `isUnlocked()` for fast UI checks.
    static func hasVerifiedEntitlement() async -> Bool {
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else { continue }
            if transaction.productID == productID, transaction.revocationDate == nil {
                return true
            }
        }
        return false
    }

    /// Synchronous fast check for UI gating. Reads cached unlock flag written by
    /// `refreshUnlockedState()` and the transaction listener.
    static func isUnlocked() -> Bool {
        UserDefaults.standard.isFullVersionUnlocked()
    }

    /// Refreshes the cached unlock flag from StoreKit. Safe to call from anywhere.
    ///
    /// Only *confirms* unlocked when StoreKit verifies an entitlement. We deliberately
    /// do NOT call `lockFullVersion()` when no entitlement is found — that would wipe
    /// the cached premium state whenever StoreKit is unreachable (user offline,
    /// simulator launched without a StoreKit Testing config, etc.).
    ///
    /// Real revocations and refunds are delivered through `Transaction.updates` and
    /// handled inside `startTransactionListener()` — that's the only place where the
    /// user is marked back to non-premium.
    @discardableResult
    static func refreshUnlockedState() async -> Bool {
        let unlocked = await hasVerifiedEntitlement()
        if unlocked {
            await MainActor.run {
                UserDefaults.standard.unlockFullVersion()
            }
        }
        return unlocked
    }

    /// Starts listening to `Transaction.updates`. Must be called once at app launch
    /// and the returned task kept alive for the lifetime of the app.
    static func startTransactionListener() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                if transaction.productID == productID {
                    let stillValid = transaction.revocationDate == nil
                    await MainActor.run {
                        if stillValid {
                            UserDefaults.standard.unlockFullVersion()
                        } else {
                            UserDefaults.standard.lockFullVersion()
                        }
                    }
                }
                await transaction.finish()
            }
        }
    }

    enum PremiumIAPError: Error {
        case productUnavailable
    }
}
