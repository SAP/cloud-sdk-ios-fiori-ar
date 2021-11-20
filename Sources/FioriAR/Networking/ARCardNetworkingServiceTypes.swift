import Foundation
import SwiftUI

public enum SourceFileType: String, Codable, Equatable, CaseIterable {
    case reality
    case usdz
}

public struct ARScene {
    public var sceneId: Int
    public var alias: String?
    public var sourceFile: ARSceneSourceFile?
    public var referenceAnchorImage: UIImage
    public var referenceAnchorImagePhysicalWidth: Double
    public var cards: [CodableCardItem]
}

internal struct ARSceneSourceFileWithData {
    public var id: String
    public var type: SourceFileType?
    public var data: Data
}

public struct ARSceneSourceFile {
    public var id: String
    public var type: SourceFileType
    public var localUrl: URL
}

public enum ARCardsNetworkingServiceError: Error, CustomStringConvertible, LocalizedError {
    case serverError(Error)
    case networkError(Error)
    case unknownError(Error)
    case cannotBeSaved
    case failure(HTTPResponseStatus)

    public var description: String {
        switch self {
        case .serverError(let error):
            return error.localizedDescription
        case .networkError(let error):
            return error.localizedDescription
        case .unknownError(let error):
            return error.localizedDescription
        case .cannotBeSaved:
            return "cannot be saved"
        case .failure(let httpResponseStatus):
            return httpResponseStatus.localizedDescription
        }
    }

    public var errorDescription: String? {
        self.description
    }
}

public struct HTTPResponseStatus: Error {
    public init(code: Int, description: String) {
        self.code = code
        self.description = description
    }

    internal init(code: Int, data: Data?) {
        self.code = code
        if let data = data {
            self.description = String(decoding: data, as: UTF8.self)
        } else {
            self.description = ""
        }
    }

    public var code: Int
    public var description: String
    public var localizedDescription: String {
        self.description
    }
}

public typealias FileImage = (id: String, image: UIImage?)
