import Foundation

/// Representing the detail/cover image of a carda
public struct CardImage: Equatable, Codable {
    /// used when loading a card specific to a scene from SAP Mobile Services
    public var id: String?

    /// data object that contains the specified image
    public var data: Data? {
        didSet {
            self.isChanged = true
        }
    }

    /// instantiates a new `CardImage` without id and withou data
    public static var new: CardImage {
        CardImage()
    }

    /// Initializer for read-only use
    public init(data: Data? = nil) {
        self.id = nil
        self.data = data
        self.isChanged = false
    }

    /// Initializer for writable use cases
    /// - Parameters:
    ///   - id: identifier of image and indicator if image exists and is persisted in remote storage service
    ///   - data: data object that contains the specified image
    internal init(id: String? = nil, data: Data? = nil) {
        self.id = id
        self.data = data
        self.isChanged = false
    }

    private var isChanged: Bool = false
    private var hasData: Bool {
        self.data?.isEmpty == false
    }

    private var isLocal: Bool {
        self.id?.isEmpty == true
    }
}

internal extension CardImage {
    enum UploadAction {
        case add(Data)
        case replace(Data)
        case remove(String)
        case ignore
    }

    var uploadAction: UploadAction {
        if !self.isLocal, self.hasData, !self.isChanged {
            return .ignore
        } else if !self.isLocal, !self.hasData, self.isChanged, let id = id {
            return .remove(id)
        } else if !self.isLocal, self.hasData, self.isChanged {
            return .replace(self.data!)
        } else if self.isLocal, !self.hasData {
            return .ignore
        } else if self.isLocal, self.hasData {
            return .add(self.data!)
        } else {
            return .ignore
        }
    }
}
