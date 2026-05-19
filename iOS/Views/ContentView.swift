import PhotosUI
import SwiftUI
import VisionKit

struct ContentView: View {
    @EnvironmentObject private var library: ScanLibrary
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showDocumentCamera = false
    @State private var showPhotoPicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedDocument: ScanDocument?
    @State private var exportedFile: SharedExport?
    @State private var showPaywall = false
    @State private var isWorking = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                SaneScanTheme.appBackground.ignoresSafeArea()
                mainContent
            }
            .navigationTitle("SaneScan")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(SaneScanTheme.background.opacity(0.92), for: .navigationBar)
            .overlay { workingOverlay }
            .modifier(ScanSheets(
                showDocumentCamera: $showDocumentCamera,
                showPhotoPicker: $showPhotoPicker,
                selectedPhotos: $selectedPhotos,
                selectedDocument: $selectedDocument,
                exportedFile: $exportedFile,
                showPaywall: $showPaywall,
                maxPhotoSelection: purchases.isPro ? 50 : 6,
                createDocument: createDocument,
                importPhotos: importPhotos,
                reportError: { errorMessage = $0 }
            ))
            .alert("SaneScan", isPresented: errorBinding, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text(errorMessage ?? "")
            })
        }
        .tint(SaneScanTheme.accent)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var mainContent: some View {
        if library.documents.isEmpty {
            EmptyLibraryView(
                onScan: startDocumentScan,
                onImport: startPhotoImport
            )
        } else {
            LibraryView(
                documents: library.documents,
                quota: library.quota(hasPro: purchases.isPro),
                isPro: purchases.isPro,
                onUpgrade: { showPaywall = true },
                onScan: startDocumentScan,
                onImport: startPhotoImport,
                onSelect: { selectedDocument = $0 },
                onDelete: { library.delete($0) }
            )
        }
    }

    @ViewBuilder
    private var workingOverlay: some View {
        if isWorking {
            ProgressView()
                .controlSize(.large)
                .tint(SaneScanTheme.accent)
                .padding(24)
                .background(SaneScanTheme.raised, in: RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("working-progress")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func startDocumentScan() {
        guard library.quota(hasPro: purchases.isPro).canCreateScan else {
            showPaywall = true
            return
        }
        if VNDocumentCameraViewController.isSupported {
            showDocumentCamera = true
        } else {
            showPhotoPicker = true
        }
    }

    private func startPhotoImport() {
        guard library.quota(hasPro: purchases.isPro).canCreateScan else {
            showPaywall = true
            return
        }
        showPhotoPicker = true
    }

    private func importPhotos(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        selectedPhotos = []
        isWorking = true
        defer { isWorking = false }

        do {
            var images: [UIImage] = []
            for item in items {
                if let data = try await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            guard !images.isEmpty else { throw ScanLibraryError.imageLoadFailed }
            await createDocument(from: images, mode: .photo)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func createDocument(from images: [UIImage], mode: ScanMode) async {
        guard !images.isEmpty else { return }
        isWorking = true
        defer { isWorking = false }

        do {
            _ = try await library.createDocument(from: images, mode: mode)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct EmptyLibraryView: View {
    let onScan: () -> Void
    let onImport: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)

            ArchiveMark(size: 142)

            Text("Start your archive")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(SaneScanTheme.primaryText)
                .multilineTextAlignment(.center)
                .shadow(color: SaneScanTheme.accentDeep.opacity(0.36), radius: 14, x: 0, y: 6)
                .accessibilityIdentifier("empty-title")

            HStack(spacing: 14) {
                PrimaryActionButton(title: "Scan", systemImage: "camera.viewfinder", action: onScan)
                    .accessibilityIdentifier("scan-button")

                SecondaryActionButton(title: "Import", systemImage: "photo", action: onImport)
                    .accessibilityIdentifier("import-button")
            }

            Spacer(minLength: 80)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct LibraryView: View {
    let documents: [ScanDocument]
    let quota: ScanQuota
    let isPro: Bool
    let onUpgrade: () -> Void
    let onScan: () -> Void
    let onImport: () -> Void
    let onSelect: (ScanDocument) -> Void
    let onDelete: (ScanDocument) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                QuotaCard(quota: quota, isPro: isPro, onUpgrade: onUpgrade)

                HStack(spacing: 14) {
                    PrimaryActionButton(title: "Scan", systemImage: "camera.viewfinder", action: onScan)
                        .accessibilityIdentifier("scan-button")

                    SecondaryActionButton(title: "Import", systemImage: "photo", action: onImport)
                        .accessibilityIdentifier("import-button")
                }
                .frame(maxWidth: .infinity)

                ForEach(documents) { document in
                    ScanRow(document: document)
                        .onTapGesture { onSelect(document) }
                        .contextMenu {
                            Button(role: .destructive) {
                                onDelete(document)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("scan-row-\(document.id.uuidString)")
                }
            }
            .padding(18)
        }
        .scrollContentBackground(.hidden)
        .background(SaneScanTheme.appBackground)
        .accessibilityIdentifier("library-view")
    }
}

private struct QuotaCard: View {
    let quota: ScanQuota
    let isPro: Bool
    let onUpgrade: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isPro ? "checkmark.seal.fill" : "gauge.with.dots.needle.67percent")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(isPro ? SaneScanTheme.proGradient : SaneScanTheme.archiveGradient)
                .frame(width: 50, height: 50)
                .background(SaneScanTheme.blueDeep.opacity(0.74), in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isPro ? SaneScanTheme.green.opacity(0.5) : SaneScanTheme.warmHairline, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(isPro ? "Pro active" : "\(quota.remainingFreeScans) free scans left")
                    .font(.headline)
                    .foregroundStyle(SaneScanTheme.primaryText)
                Text(isPro ? "Unlimited scans" : "Go unlimited")
                    .font(.subheadline)
                    .foregroundStyle(SaneScanTheme.secondaryText)
            }

            Spacer()

            if isPro {
                ProStatusPill()
            } else {
                GradientActionPill(title: "Upgrade", action: onUpgrade)
                    .accessibilityIdentifier("upgrade-button")
            }
        }
        .padding(16)
        .premiumPanel()
    }
}

private struct ProStatusPill: View {
    var body: some View {
        Text("Active")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(SaneScanTheme.primaryText)
            .padding(.horizontal, 18)
            .frame(height: 44)
            .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(SaneScanTheme.green.opacity(0.5), lineWidth: 1)
            )
            .accessibilityIdentifier("pro-active-pill")
    }
}

private struct ScanRow: View {
    let document: ScanDocument

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: document.mode == .photo ? "photo" : "doc.text.viewfinder")
                .font(.title2)
                .foregroundStyle(SaneScanTheme.accentSoft)
                .frame(width: 46, height: 46)
                .background(SaneScanTheme.blueDeep, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(SaneScanTheme.accent.opacity(0.5), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(document.title)
                    .font(.headline)
                    .foregroundStyle(SaneScanTheme.primaryText)
                Text("\(document.pages.count) page\(document.pages.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(SaneScanTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(SaneScanTheme.secondaryText)
        }
        .padding(16)
        .premiumPanel()
    }
}
