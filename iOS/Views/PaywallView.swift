import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ZStack {
                SaneScanTheme.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        PaywallHero()
                        PaywallFeature(title: "Document and photo scans", systemImage: "doc.viewfinder")
                        PaywallFeature(title: "Batch import up to 50 images", systemImage: "square.stack.3d.up")
                        PaywallFeature(title: "Local OCR and PDF export", systemImage: "text.viewfinder")
                        donateSection
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Support SaneScan")
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

    private var donateSection: some View {
        VStack(spacing: 12) {
            Text("SaneScan is free and open source. Every scan tool stays unlocked.")
                .font(.headline)
                .foregroundStyle(SaneScanTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                openURL(OpenSourceRelease.donationURL)
            } label: {
                HStack {
                    Text("Donate")
                    Spacer()
                    Image(systemName: "heart.fill")
                }
                .font(.headline)
                .foregroundStyle(SaneScanTheme.primaryText)
                .padding(16)
                .background(SaneScanTheme.premiumGradient, in: RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityIdentifier("donate-button")
            Button("Contribute on GitHub") {
                openURL(URL(string: "https://github.com/sane-apps/SaneScan")!)
            }
            .foregroundStyle(SaneScanTheme.primaryText)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
            .accessibilityIdentifier("contribute-button")
        }
    }

}

private struct PaywallHero: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(SaneScanTheme.proGradient)
            Text("SaneScan is free")
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
