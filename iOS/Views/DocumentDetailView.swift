import SwiftUI

struct DocumentDetailView: View {
    @EnvironmentObject private var library: ScanLibrary
    @Environment(\.dismiss) private var dismiss
    let document: ScanDocument
    @Binding var exportedFile: SharedExport?
    @State private var isExporting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                SaneScanTheme.appBackground.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(document.pages) { page in
                            ScanPageView(page: page)
                        }

                        if !document.recognizedText.isEmpty {
                            recognizedTextSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(SaneScanTheme.background.opacity(0.92), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(SaneScanTheme.primaryText)
                        .accessibilityIdentifier("detail-done")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await exportPDF() }
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .disabled(isExporting)
                    .accessibilityIdentifier("export-button")
                }
            }
            .overlay {
                if isExporting {
                    ProgressView()
                        .controlSize(.large)
                .tint(SaneScanTheme.accent)
                .padding(24)
                .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(SaneScanTheme.hairline, lineWidth: 1)
                )
        }
    }
            .alert("Export failed", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .sheet(item: $exportedFile) { file in
                ShareSheet(items: [file.url])
                    .preferredColorScheme(.dark)
            }
        }
    }

    private var recognizedTextSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recognized Text")
                .font(.headline)
                .foregroundStyle(SaneScanTheme.primaryText)
            Text(document.recognizedText)
                .font(.body.monospaced())
                .foregroundStyle(SaneScanTheme.secondaryText)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SaneScanTheme.hairline, lineWidth: 1)
        )
        .accessibilityIdentifier("recognized-text")
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    private func exportPDF() async {
        isExporting = true

        do {
            let url = try await library.exportPDF(for: document)
            isExporting = false
            exportedFile = SharedExport(url: url)
        } catch {
            isExporting = false
            errorMessage = error.localizedDescription
        }
    }
}

private struct ScanPageView: View {
    @EnvironmentObject private var library: ScanLibrary
    let page: ScanPage

    var body: some View {
        Group {
            if let image = library.image(for: page) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .background(SaneScanTheme.panelGradient, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(SaneScanTheme.warmHairline, lineWidth: 1)
                    )
                    .accessibilityIdentifier("scan-page-image")
            } else {
                ContentUnavailableView("Image unavailable", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(SaneScanTheme.primaryText)
                    .accessibilityIdentifier("image-unavailable")
            }
        }
        .frame(maxWidth: .infinity)
    }
}
