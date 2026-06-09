import Foundation
import StoreKit

enum PurchaseFunnelEvent: String {
    case paywallShown = "paywall_shown"
    case productLoaded = "product_loaded"
    case productLoadFailed = "product_load_failed"
    case purchaseStarted = "purchase_started"
    case purchaseCompleted = "purchase_completed"
    case purchaseCancelled = "purchase_cancelled"
    case purchasePending = "purchase_pending"
    case purchaseFailed = "purchase_failed"
    case restoreCompleted = "restore_completed"
    case restoreFailed = "restore_failed"
}

enum SaneScanEventTracker {
    private static let endpoint = "https://dist.saneapps.com/api/event"

    static func log(_ event: PurchaseFunnelEvent) async {
        var components = URLComponents(string: endpoint)
        components?.queryItems = telemetryPayload(event: event.rawValue)
            .sorted { $0.key < $1.key }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components?.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        _ = try? await URLSession.shared.data(for: request)
    }

    static func telemetryPayload(
        event: String,
        appVersion: String = bundleValue("CFBundleShortVersionString"),
        build: String = bundleValue("CFBundleVersion"),
        osVersion: String = osVersion()
    ) -> [String: String] {
        [
            "app": "sanescan",
            "event": event,
            "app_version": appVersion,
            "build": build,
            "os_version": osVersion,
            "platform": "ios",
            "channel": "app_store"
        ]
    }

    private static func bundleValue(_ key: String) -> String {
        (Bundle.main.object(forInfoDictionaryKey: key) as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty ?? "unknown"
    }

    private static func osVersion() -> String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
}

@MainActor
final class PurchaseManager: ObservableObject {
    nonisolated static let yearlyID = "com.sanescan.app.pro.yearly6"
    nonisolated static let activeProductIDs = [yearlyID]

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

    func recordPaywallShown() {
        trackFunnel(.paywallShown)
    }

    func purchasePro(_ product: Product) async {
        purchaseError = nil
        trackFunnel(.purchaseStarted)
        do {
            let result = try await product.purchase()
            switch result {
            case let .success(verification):
                _ = try checkVerified(verification)
                await updateEntitlements()
                purchaseError = nil
                trackFunnel(.purchaseCompleted)
            case .userCancelled, .pending:
                if case .userCancelled = result {
                    trackFunnel(.purchaseCancelled)
                } else {
                    trackFunnel(.purchasePending)
                }
                break
            @unknown default:
                trackFunnel(.purchaseFailed)
                break
            }
        } catch {
            purchaseError = Self.purchaseFailedMessage
            trackFunnel(.purchaseFailed)
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
            trackFunnel(.restoreCompleted)
        } catch {
            purchaseError = Self.purchaseFailedMessage
            trackFunnel(.restoreFailed)
        }
    }

    private func loadProducts() async {
        do {
            products = try await Product.products(for: Self.activeProductIDs)
                .sorted { productRank($0.id) < productRank($1.id) }
            purchaseError = nil
            trackFunnel(products.isEmpty ? .productLoadFailed : .productLoaded)
        } catch {
            purchaseError = Self.temporarilyUnavailableMessage
            trackFunnel(.productLoadFailed)
        }
    }

    private func productRank(_ productID: String) -> Int {
        switch productID {
        case Self.yearlyID:
            0
        default:
            1
        }
    }

    private func updateEntitlements() async {
        var unlocked = false
        for await entitlement in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(entitlement) else { continue }
            if transaction.productID == Self.yearlyID {
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

    private func trackFunnel(_ event: PurchaseFunnelEvent) {
        Task.detached {
            await SaneScanEventTracker.log(event)
        }
    }

    nonisolated static let temporarilyUnavailableMessage =
        "Purchases are temporarily unavailable. Please try again in a moment."
    nonisolated static let purchaseFailedMessage = "Purchase could not be completed. Please try again in a moment."
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
