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
                        PaywallFeature(title: "OCR text and PDF export", systemImage: "doc.richtext")
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
        if purchases.products.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Products unavailable")
                    .font(.headline)
                    .foregroundStyle(SaneScanTheme.primaryText)
                Text("StoreKit products need App Store Connect setup before purchase testing.")
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
        } else {
            ForEach(purchases.products, id: \.id) { product in
                Button {
                    Task { await purchases.purchase(product) }
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
    }
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
