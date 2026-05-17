import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let yearlyID = "com.sanescan.app.pro.yearly"
    static let lifetimeID = "com.sanescan.app.pro.lifetime"

    @Published private(set) var products: [Product] = []
    @Published private(set) var hasPro = false
    @Published var purchaseError: String?

    func refresh() async {
        await loadProducts()
        await updateEntitlements()
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                _ = try checkVerified(verification)
                await updateEntitlements()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await updateEntitlements()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.yearlyID, Self.lifetimeID])
                .sorted { $0.displayPrice < $1.displayPrice }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func updateEntitlements() async {
        var unlocked = false
        for await entitlement in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(entitlement) else { continue }
            if transaction.productID == Self.yearlyID || transaction.productID == Self.lifetimeID {
                unlocked = true
            }
        }
        hasPro = unlocked
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.unknown
        case .verified(let safe):
            return safe
        }
    }
}
