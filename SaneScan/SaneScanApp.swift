import SwiftUI

@main
struct SaneScanApp: App {
    @StateObject private var library = ScanLibrary()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
                .environmentObject(purchases)
                .modifier(UITestDynamicTypeModifier())
                .task {
                    library.load()
                    library.installUITestFixtureIfNeeded()
                    purchases.startTransactionListener()
                    await purchases.refresh()
                }
                .preferredColorScheme(.dark)
        }
    }
}

private struct UITestDynamicTypeModifier: ViewModifier {
    func body(content: Content) -> some View {
        if ProcessInfo.processInfo.arguments.contains("--sanescan-large-text-preview") {
            content.dynamicTypeSize(.accessibility2)
        } else {
            content
        }
    }
}
