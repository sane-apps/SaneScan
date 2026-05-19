import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let yearlyID = "com.sanescan.app.pro.annual"
    static let lifetimeID = "com.sanescan.app.pro.lifetime"

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPro = false
    @Published var purchaseError: String?

    private var transactionListener: Task<Void, Never>?

    deinit {
        transactionListener?.cancel()
    }

    func startTransactionListener() {
        guard transactionListener == nil else { return }
        transactionListener = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                if let transaction = try? checkVerified(update) {
                    await transaction.finish()
                }
                await updateEntitlements()
            }
        }
    }

    func refresh() async {
        await loadProducts()
        await updateEntitlements()
    }

    func refreshProductsIfNeeded() async {
        guard products.isEmpty else { return }
        await loadProducts()
    }

    func purchasePro(_ product: Product) async {
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case let .success(verification):
                _ = try checkVerified(verification)
                await updateEntitlements()
                purchaseError = nil
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = Self.purchaseFailedMessage
        }
    }

    func purchase(_ product: Product) async {
        await purchasePro(product)
    }

    func restore() async {
        purchaseError = nil
        do {
            try await AppStore.sync()
            await updateEntitlements()
            await refreshProductsIfNeeded()
            purchaseError = nil
        } catch {
            purchaseError = Self.purchaseFailedMessage
        }
    }

    private func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.yearlyID, Self.lifetimeID])
                .sorted { productRank($0.id) < productRank($1.id) }
            purchaseError = nil
        } catch {
            purchaseError = Self.temporarilyUnavailableMessage
        }
    }

    private func productRank(_ productID: String) -> Int {
        switch productID {
        case Self.yearlyID:
            0
        case Self.lifetimeID:
            1
        default:
            2
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
        isPro = unlocked
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.unknown
        case let .verified(safe):
            return safe
        }
    }

    nonisolated static let temporarilyUnavailableMessage =
        "Purchases are temporarily unavailable. Please try again in a moment."
    nonisolated static let purchaseFailedMessage = "Purchase could not be completed. Please try again in a moment."
}
