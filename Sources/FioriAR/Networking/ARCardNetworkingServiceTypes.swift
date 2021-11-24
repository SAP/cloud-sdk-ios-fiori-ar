import Foundation
import SwiftUI

enum SourceFileType: String, Codable, Equatable, CaseIterable {
    case reality
    case usdz
}

struct ARScene {
    var sceneId: Int
    var alias: String?
    var sourceFile: ARSceneSourceFile?
    var referenceAnchorImage: UIImage
    var referenceAnchorImagePhysicalWidth: Double
    var cards: [CodableCardItem]
}

struct ARSceneSourceFileWithData {
    var id: String
    var type: SourceFileType?
    var data: Data
}

struct ARSceneSourceFile {
    var id: String
    var type: SourceFileType
    var localUrl: URL
}

enum ARCardsNetworkingServiceError: Error, CustomStringConvertible, LocalizedError {
    case serverError(Error)
    case networkError(Error)
    case unknownError(Error)
    case cannotBeSaved
    case failure(HTTPResponseStatus)

    var description: String {
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

    var errorDescription: String? {
        self.description
    }
}

struct HTTPResponseStatus: Error {
    init(code: Int, description: String) {
        self.code = code
        self.description = description
    }

    init(code: Int, data: Data?) {
        self.code = code
        if let data = data {
            self.description = String(decoding: data, as: UTF8.self)
        } else {
            self.description = ""
        }
    }

    var code: Int
    var description: String
    var localizedDescription: String {
        self.description
    }
}

typealias FileImage = (id: String, image: UIImage?)
