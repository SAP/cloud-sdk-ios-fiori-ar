import Combine
import SAPFoundation
import SwiftUI

typealias FileData = (id: String, data: Data?)

/**
 Networking API to fetch information from Mobile Service Argument Reality storage

 Offers aysnc functions using either Combine's `AnyPublisher` or classic completionHandler  based APIs

 - Depends on SAPFoundations `SAPURLSession`
 */
public struct ARCardsNetworkingService {
    private var sapURLSession: SAPURLSession
    private var baseURL: String

    private var cancellables = Set<AnyCancellable>()

    public init(sapURLSession: SAPURLSession, baseURL: String) {
        self.sapURLSession = sapURLSession
        self.baseURL = baseURL
    }

    // MARK: getCards - CompletionHandler

    internal func getUnresolvedAnnotationAnchors(for sceneId: Int, completionHandler: @escaping (Result<[AnnotationAnchor], ARCardsNetworkingServiceError>) -> Void) {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        api.makeRequest(ARService.Scene.GetSceneById.Request(sceneId: sceneId, language: nil)) { response in
            switch response.result {
            case .success(let data):
                guard data.successful, let scene = data.success else {
                    return completionHandler(.success([]))
                }

                guard let annotationAnchors = scene.annotationAnchors else {
                    return completionHandler(.success([]))
                }
                completionHandler(.success(annotationAnchors))

            case .failure(let apiClientError):
                completionHandler(.failure(self.sdkClientError(from: apiClientError)))
            }
        }
    }

    // MARK: getImage - CompletionHandler

    public func getImage(fileId id: String, sceneId: Int, completionHandler: @escaping (Result<UIImage?, ARCardsNetworkingServiceError>) -> Void) {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        api.makeRequest(ARService.File.GetFileById.Request(sceneId: sceneId, fileId: id)) { response in
            switch response.result {
            case .success(let data):
                guard data.successful, let imageData = data.success else { return completionHandler(.success(nil)) }
                completionHandler(.success(UIImage(data: imageData)))
            case .failure(let apiClientError):
                completionHandler(.failure(self.sdkClientError(from: apiClientError)))
            }
        }
    }

    // MARK: getImage - Combine

    public func getImage(fileId id: String, sceneId: Int) -> AnyPublisher<FileImage, Error> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.File.GetFileById.Request(sceneId: sceneId, fileId: id))
            .tryMap { response in
                switch response.result {
                case .success(let data):
                    guard data.successful, let imageData = data.success else { return (id, nil) }
                    return (id, UIImage(data: imageData))
                case .failure(let apiClientError):
                    throw apiClientError
                }
            }
            .mapError { error in
                self.sdkClientError(from: error as! APIClientError)
            }
            .eraseToAnyPublisher()
    }

    internal func getFile(fileId id: String, sceneId: Int) -> AnyPublisher<FileData, Error> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.File.GetFileById.Request(sceneId: sceneId, fileId: id))
            .tryMap { response in
                switch response.result {
                case .success(let data):
                    guard data.successful, let fileData = data.success else { return (id, nil) }
                    return (id, fileData)
                case .failure(let apiClientError):
                    throw apiClientError
                }
            }
            .mapError { error in
                self.sdkClientError(from: error as! APIClientError)
            }
            .eraseToAnyPublisher()
    }

    internal func getSourceFile(for scene: Scene) -> AnyPublisher<ARSceneSourceFileWithData?, Error> {
        if let fileId = scene.sourceFile {
            return self.getFile(fileId: fileId, sceneId: scene.id)
                .map { result in
                    ARSceneSourceFileWithData(id: fileId, type: SourceFileType(rawValue: scene.sourceFileType!.rawValue)!, data: result.data!)
                }
                .mapError { error in
                    self.sdkClientError(from: error as! APIClientError)
                }
                .eraseToAnyPublisher()
        } else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }

    // MARK: getCards - Combine

    /// fetch AR card information from Mobile Service Argument Reality storage (incl. resolving file reference)
    /// - Parameters:
    ///   - sceneId: uautoupdatingCurrent niqiue identifier for a scene describing an argument reality experience with annotations
    ///   - language: for which texts shall be returned (ISO-631-1)
    /// - Returns: AR cards (incl. image data if available)
    public func getCards(for sceneId: Int, language: String = NSLocale.autoupdatingCurrent.languageCode ?? NSLocale.preferredLanguages.first ?? "en") -> AnyPublisher<[CodableCardItem], Error> {
        let scenePublisher = self.getUnresolvedScene(for: sceneId, language: language)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()

        let filesPublisher = scenePublisher
            .mapError { $0 as Error }
            .map { scene -> [AnnotationAnchor] in
                scene.annotationAnchors ?? []
            }
            .flatMap { cards -> AnyPublisher<AnnotationAnchor, Error> in
                Publishers.Sequence(sequence: cards)
                    .eraseToAnyPublisher()
            }
            .compactMap { anchor in
                anchor.card.image
            }
            .flatMap { fileId -> AnyPublisher<FileImage, Error> in
                self.getImage(fileId: fileId, sceneId: sceneId)
                    .eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()

        return Publishers.Zip(scenePublisher, filesPublisher)
            .flatMap { scene, files -> AnyPublisher<[CodableCardItem], Error> in

                var cards: [CodableCardItem] = []

                // resolve cards, i.e. merge image data into card (if available)
                for anchor in scene.annotationAnchors ?? [] {
                    var data: Data?
                    if let fileId = anchor.card.image, let file = files.first(where: { $0.id == fileId }), let uiimage = file.image {
                        data = uiimage.pngData()
                    }

                    let card = CodableCardItem(
                        id: anchor.id,
                        title_: anchor.card.title ?? "",
                        subtitle_: anchor.card.description ?? "",
                        detailImage_: data,
                        actionText_: anchor.card.actionText,
                        icon_: nil
                    )

                    cards.append(card)
                }

                return Just(cards)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func getScene(for sceneId: Int, language: String = NSLocale.autoupdatingCurrent.languageCode ?? NSLocale.preferredLanguages.first ?? "en") -> AnyPublisher<ARScene, Error> {
        let scenePublisher = self.getUnresolvedScene(for: sceneId, language: language)
            .mapError { $0 as Error }
            .share()
            .eraseToAnyPublisher()

        let sourceFilePublisher = scenePublisher
            .mapError { $0 as Error }
            .map { scene in
                self.getSourceFile(for: scene)
                    .eraseToAnyPublisher()
            }
            .flatMap { result in
                result
            }
            .eraseToAnyPublisher()

        let imagesFilesPublisher = scenePublisher
            .mapError { $0 as Error }
            .map { scene -> [AnnotationAnchor] in
                scene.annotationAnchors ?? []
            }
            .flatMap { cards -> AnyPublisher<AnnotationAnchor, Error> in
                Publishers.Sequence(sequence: cards)
                    .eraseToAnyPublisher()
            }
            .compactMap { anchor in
                anchor.card.image
            }
            .flatMap { fileId -> AnyPublisher<FileImage, Error> in
                self.getImage(fileId: fileId, sceneId: sceneId)
                    .eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()

        return Publishers.Zip3(scenePublisher, imagesFilesPublisher, sourceFilePublisher)
            .flatMap { scene, imageFiles, sourceFile -> AnyPublisher<ARScene, Error> in

                var cards: [CodableCardItem] = []

                // resolve cards, i.e. merge image data into card (if available)
                for anchor in scene.annotationAnchors ?? [] {
                    var data: Data?
                    if let fileId = anchor.card.image, let file = imageFiles.first(where: { $0.id == fileId }), let uiimage = file.image {
                        data = uiimage.pngData()
                    }

                    let card = CodableCardItem(
                        id: anchor.id,
                        title_: anchor.card.title ?? "",
                        subtitle_: anchor.card.description ?? "",
                        detailImage_: data,
                        actionText_: anchor.card.actionText,
                        icon_: anchor.marker.icon?.sfSymbolName() ?? anchor.marker.iconIos,
                        position_: ((anchor.relPositionx != nil) && (anchor.relPositiony != nil) && (anchor.relPositionz != nil)) ? SIMD3<Float>(x: Float(anchor.relPositionx!), y: Float(anchor.relPositiony!), z: Float(anchor.relPositionz!)) : nil
                    )
                    cards.append(card)
                }

                var sourceFileUrl: ARSceneSourceFile?
                if let f = sourceFile {
                    sourceFileUrl = try! self.save(sourceFile: f)
                }
                // TODO: scene.referenceAnchor.data is of type String, need a UIImage
                // What is the referenceAnchors Image File id?
                // let anchorFile = imageFiles.first(where: { $0.id == ??? })
                // TODO: Pass in annotationAnchorImage
                let arScene = ARScene(sceneId: scene.id, sourceFile: sourceFileUrl, annotationAnchorImage: UIImage(named: "qrImage")!, annotationAnchorImagePhysicalWidth: scene.referenceAnchor?.physicalWidth ?? 0.1, cards: cards)

                return Just(arScene)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: createScene - Combine
    
    public func createScene(identifiedBy anchorImage: Data, anchorImagePhysicalWidth width: Double, cards: [CodableCardItem]) -> AnyPublisher<Int, Error> {
        let sceneId = 123 // TODO: Generated on Server? What to pass in below?
        let imageAnchorFormDataName = UUID().uuidString
        let imageAnchorFileName = "qrImage.png" // TODO: What name should be used for image Anchor?

        let refAnchor = ReferenceAnchor(data: imageAnchorFormDataName, name: imageAnchorFileName, physicalWidth: width, type: .image)
        let anchorImageUploadFile = UploadFile(type: .data(anchorImage), fileName: imageAnchorFileName, partName: imageAnchorFormDataName, mimeType: "image/png")
        let files: [UploadFile] = [anchorImageUploadFile]
        
        let annotationAnchors: [AnnotationAnchor] = cards.map { card in
            let annotationAnchor = AnnotationAnchor(
                card: Card(
                    language: NSLocale.autoupdatingCurrent.languageCode ?? NSLocale.preferredLanguages.first ?? "en",
                    actionData: card.actionContentURL_?.absoluteString,
                    actionText: card.actionText_,
                    actionType: (card.actionContentURL_ != nil) ? .link : nil,
                    description: card.subtitle_,
                    image: nil, // TODO: Handle image data? Is this the image Name?
                    title: card.title_
                ),
                id: card.id,
                marker: (card.icon_ != nil) ? Marker(icon: Marker.Icon.create(from: card.icon_!), iconAndroid: nil, iconIos: card.icon_) : Marker(icon: nil, iconAndroid: nil, iconIos: card.icon_),
                sceneId: sceneId,
                relPositionx: (card.position_ != nil) ? Double(card.position_!.x) : nil,
                relPositiony: (card.position_ != nil) ? Double(card.position_!.y) : nil,
                relPositionz: (card.position_ != nil) ? Double(card.position_!.z) : nil
            )
            // TODO: What to pass in for detailImage fileName
            // TODO: Any issue if the card image is encoded from a jpg?
            if let cardImageData = card.detailImage_ {
                // let uploadImage = UploadFile(type: .data(cardImageData), fileName: ???, partName: card.id, mimeType: "image/png")
                // files.append(uploadImage)
            }
            return annotationAnchor
        }
        
        // TODO: Alias to be passed in on scene Creation
        let scene = Scene(id: sceneId, alias: nil, annotationAnchors: annotationAnchors, nameInSourceFile: nil, referenceAnchor: refAnchor, sourceFile: nil, sourceFileType: nil)
        let jsonDataScene = try! JSONEncoder().encode(scene)
        let jsonStringScene = String(data: jsonDataScene, encoding: .utf8)!

        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.Scene.AddScene.Request(scene: jsonStringScene, files: files))
            .tryMap { response in
                switch response.result {
                case .success(let data):
                    guard let createdScene = data.success else { throw APIClientError.failure(HTTPResponseStatus(code: data.statusCode, data: response.data)) }
                    return createdScene.id
                case .failure(let apiClientError):
                    throw apiClientError
                }
            }
            .mapError { error in
                self.sdkClientError(from: error as! APIClientError)
            }
            .eraseToAnyPublisher()
    }
    
    public func updateScene(sceneId: Int, identifiedBy anchorImage: Data, anchorImagePhysicalWidth width: Double, cards: [CodableCardItem]) -> AnyPublisher<String, Error> {
        // TODO: Update ReferenceAnchor Image
        // let refAnchor = ReferenceAnchor(data: imageAnchorFormDataName, name: imageAnchorFileName, physicalWidth: width, type: .image)
        // let anchorImageUploadFile = UploadFile(type: .data(anchorImage), fileName: imageAnchorFileName, partName: imageAnchorFormDataName, mimeType: "image/png")

        let annotationAnchors = cards.map { card in
            AnnotationAnchor(
                card: Card(
                    language: NSLocale.autoupdatingCurrent.languageCode ?? NSLocale.preferredLanguages.first ?? "en",
                    actionData: card.actionContentURL_?.absoluteString,
                    actionText: card.actionText_,
                    actionType: (card.actionContentURL_ != nil) ? .link : nil,
                    description: card.subtitle_,
                    image: nil, // TODO: Handle image data? Is this the image Name?
                    title: card.title_
                ),
                id: card.id,
                marker: (card.icon_ != nil) ? Marker(icon: Marker.Icon.create(from: card.icon_!), iconAndroid: nil, iconIos: card.icon_) : Marker(icon: nil, iconAndroid: nil, iconIos: card.icon_),
                sceneId: sceneId,
                relPositionx: (card.position_ != nil) ? Double(card.position_!.x) : nil,
                relPositiony: (card.position_ != nil) ? Double(card.position_!.y) : nil,
                relPositionz: (card.position_ != nil) ? Double(card.position_!.z) : nil
            )
        }
        let scene = Scene(id: sceneId, alias: nil, annotationAnchors: annotationAnchors, nameInSourceFile: nil, referenceAnchor: nil, sourceFile: nil, sourceFileType: nil)
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        
        // TODO: Request does not accept Files to update card images or refAnchor image
        // TODO: Creating new card and then updating does not reflect on server. Only updates existing cards when fetched.
        let request = ARService.Scene.UpdateScene.Request(sceneId: sceneId, body: scene)

        return api.makeRequest(request)
            .tryMap { response in
                switch response.result {
                case .success(let data):
                    guard let createdScene = data.success else { throw APIClientError.failure(HTTPResponseStatus(code: data.statusCode, data: response.data)) }
                    return createdScene
                case .failure(let apiClientError):
                    print(apiClientError.name)
                    throw apiClientError
                }
            }
            .mapError { error in
                print((error as! APIClientError).name)
                return self.sdkClientError(from: error as! APIClientError)
            }
            .eraseToAnyPublisher()
    }

//    TODO: Method for deleting a scene
//    public func deleteScene(...) {
//
//    }

    internal func save(sourceFile: ARSceneSourceFileWithData, into directory: URL = FileManager.default.temporaryDirectory) throws -> ARSceneSourceFile {
        let localFileURL = directory.appendingPathComponent(sourceFile.id)
        guard let absoluteDirectory = URL(string: "file://" + localFileURL.path) else {
            throw ARCardsNetworkingServiceError.cannotBeSaved
        }

        do {
            try FileManager.default.removeItem(atPath: absoluteDirectory.path)
        } catch {
            () // ignore
        }

        if !FileManager.default.fileExists(atPath: absoluteDirectory.path) {
            try sourceFile.data.write(to: absoluteDirectory)
        }

        return ARSceneSourceFile(id: sourceFile.id, type: sourceFile.type, localUrl: localFileURL)
    }

    internal func getUnresolvedScene(for sceneId: Int, language: String) -> AnyPublisher<Scene, ARCardsNetworkingServiceError> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.Scene.GetSceneById.Request(sceneId: sceneId, language: language))
            .tryMap { response in
                switch response.result {
                case .success(let data):
                    guard let scene = data.success else { throw APIClientError.failure(HTTPResponseStatus(code: data.statusCode, data: response.data)) }
                    return scene
                case .failure(let apiClientError):
                    throw apiClientError
                }
            }
            .mapError { error in
                self.sdkClientError(from: error as! APIClientError)
            }
            .eraseToAnyPublisher()
    }

    internal func getUnresolvedAnnotationAnchors(for sceneId: Int, language: String) -> AnyPublisher<[AnnotationAnchor], ARCardsNetworkingServiceError> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.Scene.GetSceneById.Request(sceneId: sceneId, language: language))
            .tryMap { response in
                try self.annotationAnchors(from: response)
            }
            .mapError { error in
                self.sdkClientError(from: error as! APIClientError)
            }
            .eraseToAnyPublisher()
    }

    private func annotationAnchors(from response: APIResponse<ARService.Scene.GetSceneById.Response>) throws -> [AnnotationAnchor] {
        let empty: [AnnotationAnchor] = []
        switch response.result {
        case .success(let data):
            guard data.successful, let scene = data.success else {
                return empty
            }

            guard let annotationAnchors = scene.annotationAnchors else {
                return empty
            }

            return annotationAnchors
        case .failure(let apiClientError):
            throw apiClientError
        }
    }

    // MARK: generic utilities

    private func sdkClientError(from apiClientError: APIClientError) -> ARCardsNetworkingServiceError {
        switch apiClientError {
        case .unexpectedStatusCode(statusCode: _, data: _):
            return ARCardsNetworkingServiceError.serverError(apiClientError)
        case .encodingError:
            return ARCardsNetworkingServiceError.serverError(apiClientError)
        case .decodingError:
            return ARCardsNetworkingServiceError.serverError(apiClientError)
        case .requestEncodingError:
            return ARCardsNetworkingServiceError.serverError(apiClientError)
        case .validationError:
            return ARCardsNetworkingServiceError.serverError(apiClientError)
        case .networkError:
            return ARCardsNetworkingServiceError.networkError(apiClientError)
        case .unknownError:
            return ARCardsNetworkingServiceError.unknownError(apiClientError)
        case .failure(let httpResponseStatus):
            return ARCardsNetworkingServiceError.failure(httpResponseStatus)
        }
    }
}
