import Foundation

public struct CardImage: Equatable, Codable {
    public var id: String?
    public var data: Data? {
        didSet {
            self.isChanged = true
        }
    }

    public static var new: CardImage {
        CardImage()
    }

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
