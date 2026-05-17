import SwiftUI
import UIKit
import VisionKit

struct DocumentCameraView: UIViewControllerRepresentable {
    let onComplete: ([UIImage]) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: VNDocumentCameraViewController, context _: Context) {}

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onComplete: ([UIImage]) -> Void
        let onCancel: () -> Void

        init(onComplete: @escaping ([UIImage]) -> Void, onCancel: @escaping () -> Void) {
            self.onComplete = onComplete
            self.onCancel = onCancel
        }

        func documentCameraViewController(
            _: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            let images = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
            onComplete(images)
        }

        func documentCameraViewControllerDidCancel(_: VNDocumentCameraViewController) {
            onCancel()
        }

        func documentCameraViewController(
            _: VNDocumentCameraViewController,
            didFailWithError _: Error
        ) {
            onCancel()
        }
    }
}
