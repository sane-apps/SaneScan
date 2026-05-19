import Foundation

enum ScanMode: String, Codable, CaseIterable, Identifiable {
    case photo
    case document
    case receipt

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .photo: "Photo"
        case .document: "Document"
        case .receipt: "Receipt"
        }
    }
}

struct ScanPage: Identifiable, Codable, Equatable {
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

struct ScanDocument: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var mode: ScanMode
    var createdAt: Date
    var pages: [ScanPage]
    var isFixture: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case mode
        case createdAt
        case pages
        case isFixture
    }

    init(
        id: UUID = UUID(),
        title: String,
        mode: ScanMode,
        createdAt: Date = Date(),
        pages: [ScanPage] = [],
        isFixture: Bool = false
    ) {
        self.id = id
        self.title = title
        self.mode = mode
        self.createdAt = createdAt
        self.pages = pages
        self.isFixture = isFixture
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        mode = try container.decode(ScanMode.self, forKey: .mode)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        pages = try container.decode([ScanPage].self, forKey: .pages)
        isFixture = try container.decodeIfPresent(Bool.self, forKey: .isFixture) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(mode, forKey: .mode)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(pages, forKey: .pages)
        try container.encode(isFixture, forKey: .isFixture)
    }

    var recognizedText: String {
        pages.map(\.recognizedText)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n\n")
    }
}

struct ScanQuota {
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
