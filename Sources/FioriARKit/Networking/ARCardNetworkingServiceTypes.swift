import Foundation
import SwiftUI

public enum SourceFileType: String, Codable, Equatable, CaseIterable {
    case reality
    case usdz
}

public struct ARScene {
    public var sceneId: Int
    public var sourceFile: ARSceneSourceFile?
    public var annotationAnchorImage: UIImage
    public var annotationAnchorImagePhysicalWidth: Double
    public var cards: [CodableCardItem]
}

internal struct ARSceneSourceFileWithData {
    public var id: String
    public var type: SourceFileType
    public var data: Data
}

public struct ARSceneSourceFile {
    public var id: String
    public var type: SourceFileType
    public var localUrl: URL
}

public enum ARCardsNetworkingServiceError: Error {
    case serverError(Error)
    case networkError(Error)
    case unknownError(Error)
    case sceneCreatedButUnknownId
    case notFound
    case cannotBeSaved
}

public typealias FileImage = (id: String, image: UIImage?)
