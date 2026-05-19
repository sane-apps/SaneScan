import CoreGraphics
import Foundation
import Vision

struct RecognizedLine {
    let text: String
    let bounds: CGRect
}

actor OCRService {
    func recognizeText(in cgImage: CGImage) throws -> String {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.revision = VNRecognizeTextRequestRevision3
        request.automaticallyDetectsLanguage = true

        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])

        return Self.sortedLines(from: request.results ?? [])
            .map(\.text)
            .joined(separator: "\n")
    }

    static func sortedLines(from observations: [VNRecognizedTextObservation]) -> [RecognizedLine] {
        observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            return RecognizedLine(text: text, bounds: observation.boundingBox)
        }
        .sorted { lhs, rhs in
            let yDelta = abs(lhs.bounds.maxY - rhs.bounds.maxY)
            if yDelta > 0.03 {
                return lhs.bounds.maxY > rhs.bounds.maxY
            }
            return lhs.bounds.minX < rhs.bounds.minX
        }
    }
}
