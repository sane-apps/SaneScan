import Foundation
import UIKit

enum ScanLibraryError: LocalizedError {
    case jpegEncodingFailed
    case imageLoadFailed

    var errorDescription: String? {
        switch self {
        case .jpegEncodingFailed: "The scan image could not be encoded."
        case .imageLoadFailed: "The scan image could not be loaded."
        }
    }
}

@MainActor
final class ScanLibrary: ObservableObject {
    @Published var documents: [ScanDocument] = []
    @Published var scansThisMonth = 0

    private let ocrService = OCRService()
    private let pdfService = PDFExportService()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    var rootURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SaneScan", isDirectory: true)
    }

    var imagesURL: URL {
        rootURL.appendingPathComponent("Images", isDirectory: true)
    }

    var exportsURL: URL {
        rootURL.appendingPathComponent("Exports", isDirectory: true)
    }

    private var libraryURL: URL {
        rootURL.appendingPathComponent("library.json")
    }

    init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    func load() {
        try? FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: exportsURL, withIntermediateDirectories: true)

        guard let data = try? Data(contentsOf: libraryURL),
              let decoded = try? decoder.decode([ScanDocument].self, from: data)
        else {
            documents = []
            scansThisMonth = 0
            return
        }

        documents = decoded.sorted { $0.createdAt > $1.createdAt }
        scansThisMonth = documents.filter {
            Calendar.current.isDate($0.createdAt, equalTo: Date(), toGranularity: .month)
        }.count
    }

    func quota(hasPro: Bool) -> ScanQuota {
        ScanQuota(hasPro: hasPro, scansThisMonth: scansThisMonth)
    }

    func createDocument(from images: [UIImage], mode: ScanMode) async throws -> ScanDocument {
        let documentID = UUID()
        var pages: [ScanPage] = []

        for image in images {
            let cleaned = ImageEnhancementService.cleanedImage(from: image)
            let originalFilename = "\(documentID.uuidString)-\(pages.count)-original.jpg"
            let enhancedFilename = "\(documentID.uuidString)-\(pages.count)-enhanced.jpg"
            try writeJPEG(image, filename: originalFilename)
            try writeJPEG(cleaned, filename: enhancedFilename)

            let text = try await recognizeText(in: cleaned)
            pages.append(ScanPage(
                imageFilename: originalFilename,
                enhancedFilename: enhancedFilename,
                recognizedText: text
            ))
        }

        let title = "\(mode.title) \(Self.titleFormatter.string(from: Date()))"
        let document = ScanDocument(id: documentID, title: title, mode: mode, pages: pages)
        documents.insert(document, at: 0)
        scansThisMonth += 1
        try save()
        return document
    }

    func image(for page: ScanPage, enhanced: Bool = true) -> UIImage? {
        let filename = enhanced ? (page.enhancedFilename ?? page.imageFilename) : page.imageFilename
        return UIImage(contentsOfFile: imagesURL.appendingPathComponent(filename).path)
    }

    func exportPDF(for document: ScanDocument) async throws -> URL {
        let data = try await pdfService.render(document: document) { [imagesURL] page in
            let filename = page.enhancedFilename ?? page.imageFilename
            guard let image = UIImage(contentsOfFile: imagesURL.appendingPathComponent(filename).path) else {
                throw PDFExportError.missingImage
            }
            return image
        }

        let filename = document.title
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-") + ".pdf"
        let url = exportsURL.appendingPathComponent(filename)
        try data.write(to: url, options: [.atomic])
        return url
    }

    func delete(_ document: ScanDocument) {
        documents.removeAll { $0.id == document.id }
        for page in document.pages {
            try? FileManager.default.removeItem(at: imagesURL.appendingPathComponent(page.imageFilename))
            if let enhancedFilename = page.enhancedFilename {
                try? FileManager.default.removeItem(at: imagesURL.appendingPathComponent(enhancedFilename))
            }
        }
        try? save()
    }

    private func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { return "" }
        return try await ocrService.recognizeText(in: cgImage)
    }

    private func writeJPEG(_ image: UIImage, filename: String) throws {
        guard let data = image.jpegData(compressionQuality: 0.92) else {
            throw ScanLibraryError.jpegEncodingFailed
        }
        try data.write(to: imagesURL.appendingPathComponent(filename), options: [.atomic])
    }

    func save() throws {
        let data = try encoder.encode(documents)
        try data.write(to: libraryURL, options: [.atomic])
    }

    private static let titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
