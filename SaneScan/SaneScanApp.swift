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
