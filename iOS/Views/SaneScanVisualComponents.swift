import SwiftUI

enum SaneScanTheme {
    static let background = Color(red: 0.03, green: 0.04, blue: 0.05)
    static let surface = Color(red: 0.09, green: 0.10, blue: 0.10)
    static let raised = Color(red: 0.13, green: 0.14, blue: 0.13)
    static let accent = Color(red: 0.05, green: 0.64, blue: 0.78)
    static let accentDeep = Color(red: 0.06, green: 0.45, blue: 0.56)
    static let accentSoft = Color(red: 0.36, green: 0.86, blue: 0.95)
    static let blue = Color(red: 0.22, green: 0.45, blue: 1.00)
    static let blueDeep = Color(red: 0.07, green: 0.14, blue: 0.32)
    static let panelTint = Color(red: 0.14, green: 0.26, blue: 0.56)
    static let green = Color(red: 0.36, green: 0.86, blue: 0.57)
    static let gold = Color(red: 0.95, green: 0.72, blue: 0.27)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.92)
    static let hairline = Color.white.opacity(0.14)
    static let warmHairline = gold.opacity(0.36)

    static let appBackground = LinearGradient(
        colors: [
            Color(red: 0.02, green: 0.03, blue: 0.04),
            blueDeep.opacity(0.72),
            background
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panelGradient = LinearGradient(
        colors: [
            panelTint.opacity(0.32),
            surface,
            Color(red: 0.07, green: 0.10, blue: 0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let premiumGradient = LinearGradient(
        colors: [accentSoft, accent, blue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let archiveGradient = LinearGradient(
        colors: [gold.opacity(0.95), accentSoft.opacity(0.95), blue.opacity(0.92)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let proGradient = LinearGradient(
        colors: [green, accentSoft, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct ArchiveMark: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(SaneScanTheme.archiveGradient)
                .frame(width: size, height: size)
                .shadow(color: SaneScanTheme.accentDeep.opacity(0.36), radius: 22, x: 0, y: 12)

            RoundedRectangle(cornerRadius: 8)
                .fill(SaneScanTheme.blueDeep.opacity(0.86))
                .frame(width: size * 0.70, height: size * 0.70)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(SaneScanTheme.hairline, lineWidth: 1)
                )

            Image(systemName: "doc.viewfinder")
                .font(.system(size: size * 0.40, weight: .semibold))
                .foregroundStyle(SaneScanTheme.accentSoft)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.warmHairline, lineWidth: 1)
        )
    }
}

struct GradientActionPill: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(SaneScanTheme.primaryText)
            .padding(.horizontal, 18)
            .frame(height: 44)
            .background(SaneScanTheme.premiumGradient, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.24), lineWidth: 1)
            )
    }
}

extension View {
    func premiumPanel() -> some View {
        background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(SaneScanTheme.hairline, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(SaneScanTheme.primaryText)
                .frame(width: 142, height: 54)
        }
        .background(SaneScanTheme.premiumGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.24), lineWidth: 1)
        )
        .shadow(color: SaneScanTheme.accentDeep.opacity(0.28), radius: 12, x: 0, y: 7)
    }
}

struct SecondaryActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(SaneScanTheme.primaryText)
                .frame(width: 142, height: 54)
        }
        .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.hairline, lineWidth: 1)
        )
    }
}
