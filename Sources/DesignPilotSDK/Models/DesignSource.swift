import Foundation

/// Defines the source format of a design: a live Figma URL or an uploaded PDF document.
public enum DesignSource: Hashable, Sendable, Codable {
    case figmaURL(FigmaURL)
    case pdf(PDFSourceInfo)

    public var displayName: String {
        switch self {
        case .figmaURL(let url):
            return url.documentTitle ?? "Figma: \(url.fileKey)"
        case .pdf(let info):
            return info.fileName
        }
    }

    public var isFigma: Bool {
        if case .figmaURL = self { return true }
        return false
    }

    public var isPDF: Bool {
        if case .pdf = self { return true }
        return false
    }

    public var figmaURL: FigmaURL? {
        if case .figmaURL(let url) = self { return url }
        return nil
    }

    public var pdfInfo: PDFSourceInfo? {
        if case .pdf(let info) = self { return info }
        return nil
    }
}

/// Metadata and payload representing an uploaded or referenced design PDF file.
public struct PDFSourceInfo: Hashable, Sendable, Codable {
    public let filePath: String
    public let fileName: String
    public let pageCount: Int
    public let selectedPage: Int
    public let fileSizeInBytes: Int
    public let fileData: Data?

    public init(
        filePath: String,
        fileName: String,
        pageCount: Int = 1,
        selectedPage: Int = 1,
        fileSizeInBytes: Int = 0,
        fileData: Data? = nil
    ) {
        self.filePath = filePath
        self.fileName = fileName
        self.pageCount = max(1, pageCount)
        self.selectedPage = max(1, min(selectedPage, pageCount))
        self.fileSizeInBytes = fileSizeInBytes
        self.fileData = fileData
    }

    public var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSizeInBytes))
    }
}
