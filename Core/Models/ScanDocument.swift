import Foundation

enum ScanMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case photo
    case document
    case receipt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photo: "Photo"
        case .document: "Document"
        case .receipt: "Receipt"
        }
    }
}

struct ScanPage: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var imageFilename: String
    var enhancedFilename: String?
    var recognizedText: String

    init(
        id: UUID = UUID(),
        imageFilename: String,
        enhancedFilename: String? = nil,
        recognizedText: String = ""
    ) {
        self.id = id
        self.imageFilename = imageFilename
        self.enhancedFilename = enhancedFilename
        self.recognizedText = recognizedText
    }
}

struct ScanDocument: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var mode: ScanMode
    var createdAt: Date
    var pages: [ScanPage]

    init(
        id: UUID = UUID(),
        title: String,
        mode: ScanMode,
        createdAt: Date = Date(),
        pages: [ScanPage] = []
    ) {
        self.id = id
        self.title = title
        self.mode = mode
        self.createdAt = createdAt
        self.pages = pages
    }

    var recognizedText: String {
        pages.map(\.recognizedText)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n\n")
    }
}

struct ScanQuota: Sendable {
    static let freeMonthlyLimit = 10

    let hasPro: Bool
    let scansThisMonth: Int

    var remainingFreeScans: Int {
        max(0, Self.freeMonthlyLimit - scansThisMonth)
    }

    var canCreateScan: Bool {
        hasPro || scansThisMonth < Self.freeMonthlyLimit
    }
}
