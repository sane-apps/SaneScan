import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchases: PurchaseManager

    var body: some View {
        NavigationStack {
            ZStack {
                SaneScanTheme.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        PaywallHero()
                        PaywallFeature(title: "Unlimited scans", systemImage: "infinity")
                        PaywallFeature(title: "Batch import up to 50 images", systemImage: "square.stack.3d.up")
                        PaywallFeature(title: "No monthly scan limit", systemImage: "gauge.with.dots.needle.100percent")
                        purchaseErrorView
                        productSection
                    }
                    .padding(18)
                }
            }
            .navigationTitle("SaneScan Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(SaneScanTheme.background.opacity(0.92), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(SaneScanTheme.primaryText)
                        .accessibilityIdentifier("paywall-done")
                }
            }
        }
        .tint(SaneScanTheme.accent)
        .accessibilityIdentifier("paywall")
        .task {
            await purchases.refreshProductsIfNeeded()
        }
    }

    @ViewBuilder
    private var purchaseErrorView: some View {
        if let purchaseError = purchases.purchaseError {
            Text(purchaseError)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SaneScanTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.red.opacity(0.42), in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
                .accessibilityIdentifier("purchase-error")
        }
    }

    @ViewBuilder
    private var productSection: some View {
        if showsPreviewProducts {
            previewProductButton(title: "Annual Pro", detail: "Unlimited scans for a full year")
            previewProductButton(title: "Lifetime Pro", detail: "One unlock for every archive")
        } else if purchases.products.isEmpty {
            productsUnavailableView
            retryPurchasesButton
        } else {
            ForEach(purchases.products, id: \.id) { product in
                Button {
                    Task { await purchases.purchasePro(product) }
                } label: {
                    HStack {
                        Text(product.displayName)
                        Spacer()
                        Text(product.displayPrice)
                    }
                    .font(.headline)
                    .foregroundStyle(SaneScanTheme.primaryText)
                    .padding(16)
                    .background(SaneScanTheme.premiumGradient, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.24), lineWidth: 1)
                    )
                }
                .accessibilityIdentifier("product-\(product.id)")
            }
        }

        subscriptionDisclosure

        if !showsPreviewProducts {
            restorePurchasesButton
        }
    }

    private var showsPreviewProducts: Bool {
        ProcessInfo.processInfo.arguments.contains("--sanescan-paywall-preview")
    }

    private func previewProductButton(title: String, detail: String) -> some View {
        Button {} label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SaneScanTheme.primaryText.opacity(0.9))
                }
                Spacer(minLength: 8)
                Text("Pro option")
                    .font(.footnote.weight(.bold))
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(SaneScanTheme.primaryText)
            }
            .foregroundStyle(SaneScanTheme.primaryText)
            .padding(16)
            .background(SaneScanTheme.premiumGradient, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.24), lineWidth: 1)
            )
        }
        .accessibilityIdentifier("preview-product-\(title.replacingOccurrences(of: " ", with: "-").lowercased())")
    }

    private var productsUnavailableView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("App Store options loading")
                .font(.headline)
                .foregroundStyle(SaneScanTheme.primaryText)
            Text("Connect to the App Store to view Pro options, or restore purchases if you already have Pro.")
                .font(.subheadline)
                .foregroundStyle(SaneScanTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.warmHairline, lineWidth: 1)
        )
        .accessibilityIdentifier("products-unavailable")
    }

    private var retryPurchasesButton: some View {
        Button("Try Again") {
            Task { await purchases.refreshProductsIfNeeded() }
        }
        .foregroundStyle(SaneScanTheme.primaryText)
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.hairline, lineWidth: 1)
        )
        .accessibilityIdentifier("retry-purchases")
    }

    private var restorePurchasesButton: some View {
        Button("Restore Purchases") {
            Task { await purchases.restore() }
        }
        .foregroundStyle(SaneScanTheme.primaryText)
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.hairline, lineWidth: 1)
        )
        .accessibilityIdentifier("restore-purchases")
    }

    private var subscriptionDisclosure: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subscription details")
                .font(.headline)
                .foregroundStyle(SaneScanTheme.primaryText)
            Text("SaneScan Pro Yearly is an auto-renewable subscription billed once per year. The App Store shows the current price, confirms renewal terms before purchase, and lets you cancel anytime in subscription settings.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SaneScanTheme.primaryText)
            HStack(spacing: 12) {
                Link("Terms of Use", destination: Self.termsURL)
                    .accessibilityIdentifier("terms-of-use-link")
                Text("•")
                    .foregroundStyle(SaneScanTheme.primaryText)
                Link("Privacy Policy", destination: Self.privacyURL)
                    .accessibilityIdentifier("privacy-policy-link")
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(SaneScanTheme.accentSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.warmHairline, lineWidth: 1)
        )
        .accessibilityIdentifier("subscription-disclosure")
    }

    private static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private static let privacyURL = URL(string: "https://sanescan.saneapps.com/privacy/")!
}

private struct PaywallHero: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(SaneScanTheme.proGradient)
            Text("SaneScan Pro")
                .font(.largeTitle.bold())
                .foregroundStyle(SaneScanTheme.primaryText)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .padding(.horizontal, 18)
        .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.warmHairline, lineWidth: 1)
        )
        .shadow(color: SaneScanTheme.accentDeep.opacity(0.28), radius: 18, x: 0, y: 10)
    }
}

private struct PaywallFeature: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(SaneScanTheme.accentSoft)
                .frame(width: 42, height: 42)
                .background(SaneScanTheme.blueDeep.opacity(0.78), in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(SaneScanTheme.accent.opacity(0.5), lineWidth: 1)
                )

            Text(title)
                .font(.headline)
                .foregroundStyle(SaneScanTheme.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.hairline, lineWidth: 1)
        )
    }
}
