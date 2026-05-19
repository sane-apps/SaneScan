import PhotosUI
import SwiftUI

struct ScanSheets: ViewModifier {
    @Binding var showDocumentCamera: Bool
    @Binding var showPhotoPicker: Bool
    @Binding var selectedPhotos: [PhotosPickerItem]
    @Binding var selectedDocument: ScanDocument?
    @Binding var exportedFile: SharedExport?
    @Binding var showPaywall: Bool
    let maxPhotoSelection: Int
    let createDocument: ([UIImage], ScanMode) async -> Void
    let importPhotos: ([PhotosPickerItem]) async -> Void
    let reportError: (String) -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showDocumentCamera) {
                DocumentCameraView { images in
                    showDocumentCamera = false
                    Task { await createDocument(images, .document) }
                } onCancel: {
                    showDocumentCamera = false
                } onError: { error in
                    showDocumentCamera = false
                    reportError(error.localizedDescription)
                }
                .preferredColorScheme(.dark)
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedPhotos,
                maxSelectionCount: maxPhotoSelection,
                matching: .images
            )
            .onChange(of: selectedPhotos) { _, items in
                Task { await importPhotos(items) }
            }
            .sheet(item: $selectedDocument) { document in
                DocumentDetailView(document: document, exportedFile: $exportedFile)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .preferredColorScheme(.dark)
            }
    }
}

struct SharedExport: Identifiable {
    let id = UUID()
    let url: URL
}
