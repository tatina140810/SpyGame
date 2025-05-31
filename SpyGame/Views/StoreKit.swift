import Foundation
import StoreKit

final class StoreKitTestLogger {
    
    static func fetchProducts(with ids: [String]) {
        Task {
            do {
                _ = try await Product.products(for: ids)
            } catch {
             
            }
        }
    }
}
