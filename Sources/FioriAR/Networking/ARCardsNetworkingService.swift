import Combine
import SAPFoundation
import SwiftUI

typealias FileData = (id: String, data: Data?)

/**
 Networking API to fetch information from Mobile Service Argument Reality storage

 Offers aysnc functions using  Combine's `AnyPublisher`

 - Depends on SAPFoundations `SAPURLSession`
 */
public struct ARCardsNetworkingService {
    private var sapURLSession: SAPURLSession
    private var baseURL: String

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public

    public init(sapURLSession: SAPURLSession, baseURL: String) {
        self.sapURLSession = sapURLSession
        self.baseURL = baseURL
    }

    /// fetch AR card information from Mobile Service Argument Reality storage (incl. resolving file reference)
    /// - Parameters:
    ///   - sceneIdentifying: id or alias which uniquely identifies the scene
    ///   - language: for which texts shall be returned (ISO-631-1)
    /// - Returns: Scene
    public func getScene(_ sceneIdentifying: SceneIdentifyingAttribute, language: String = NSLocale.autoupdatingCurrent.languageCode ?? NSLocale.preferredLanguages.first ?? "en") -> AnyPublisher<ARScene, Error> {
        var sceneId: Int!
        let scenePublisher = scenePublisher(for: sceneIdentifying, language: language)
            .mapError { $0 as Error }
            .share()
            .eraseToAnyPublisher()

        let referenceAnchorImagePublisher = scenePublisher
            .mapError { $0 as Error }
            .map { scene in
                self.getReferenceAnchorFile(for: scene)
                    .eraseToAnyPublisher()
            }
            .flatMap { result in
                result
            }
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
                sceneId = scene.id
                return scene.annotationAnchors ?? []
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

        return Publishers.Zip4(scenePublisher, referenceAnchorImagePublisher, imagesFilesPublisher, sourceFilePublisher)
            .flatMap { scene, referenceAnchorFile, imageFiles, sourceFile -> AnyPublisher<ARScene, Error> in

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
                        subtitle_: anchor.card.description,
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

                guard let referenceAnchorFile = referenceAnchorFile,
                      let referenceAnchorImage = UIImage(data: referenceAnchorFile.data) else { fatalError() }

                let arScene = ARScene(sceneId: scene.id, alias: scene.alias, sourceFile: sourceFileUrl, referenceAnchorImage: referenceAnchorImage, referenceAnchorImagePhysicalWidth: scene.referenceAnchor?.physicalWidth ?? 0.1, cards: cards)

                return Just(arScene)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public func createScene(identifiedBy anchorImage: Data, anchorImagePhysicalWidth width: Double, anchorImageFileName: String = "anchorImage.png", cards: [CodableCardItem], sceneAlias: String? = nil) -> AnyPublisher<Int, Error> {
        let sceneId = 3537 // server ignores sceneId for POST and will generate sceneId. As we don't want to make sceneId optional for the model let's pass a dummy value
        let imageAnchorFormDataName = UUID().uuidString
        let imageAnchorFileName = anchorImageFileName // name is only shown in Mobile Service cockpit as of now

        let refAnchor = ReferenceAnchor(data: imageAnchorFormDataName, name: imageAnchorFileName, physicalWidth: width, type: .image)
        let anchorImageUploadFile = UploadFile(type: .data(anchorImage), fileName: imageAnchorFileName, partName: imageAnchorFormDataName, mimeType: "image/png")
        var files: [UploadFile] = [anchorImageUploadFile]

        let annotationAnchors: [AnnotationAnchor] = cards.map { card in

            var imageUploadName: String?
            if let imageData = card.detailImage_ {
                imageUploadName = UUID().uuidString
                files.append(UploadFile(type: .data(imageData), fileName: imageUploadName!, partName: imageUploadName!, mimeType: "image/png")) // a mime type is needed for multi-form request but it does not matter if it's png or jpeg
            }

            return AnnotationAnchor(
                card: Card(
                    language: NSLocale.autoupdatingCurrent.languageCode ?? NSLocale.preferredLanguages.first ?? "en",
                    actionData: card.actionContentURL_?.absoluteString,
                    actionText: card.actionText_,
                    actionType: (card.actionContentURL_ != nil) ? .link : nil,
                    description: card.subtitle_,
                    image: imageUploadName,
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

        let scene = Scene(id: sceneId, alias: sceneAlias, annotationAnchors: annotationAnchors, nameInSourceFile: nil, referenceAnchor: refAnchor, sourceFile: nil, sourceFileType: nil)
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

    public func updateScene(_ sceneId: Int, identifiedBy anchorImage: Data, anchorImagePhysicalWidth width: Double, cards: [CodableCardItem]) -> AnyPublisher<String, Error> {
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

    public func deleteScene(_ sceneId: Int) -> AnyPublisher<Void, Error> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        let request = ARService.Scene.DeleteScene.Request(sceneId: sceneId)

        return api.makeRequest(request)
            .tryMap { response in
                switch response.result {
                case .success(let data):
                    guard data.success != nil else { throw APIClientError.failure(HTTPResponseStatus(code: data.statusCode, data: response.data)) }
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

    // MARK: Others

    private func scenePublisher(for sceneIdentifier: SceneIdentifyingAttribute, language: String) -> AnyPublisher<Scene, ARCardsNetworkingServiceError> {
        switch sceneIdentifier {
        case .id(id: let id):
            return self.getUnresolvedScene(for: id, language: language)
        case .alias(alias: let alias):
            return self.getUnresolvedScene(for: alias, language: language)
        }
    }

    internal func getImage(fileId id: String, sceneId: Int) -> AnyPublisher<FileImage, Error> {
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

    internal func getReferenceAnchorFile(for scene: Scene) -> AnyPublisher<ARSceneSourceFileWithData?, Error> {
        if let fileId = scene.referenceAnchor?.data {
            return self.getFile(fileId: fileId, sceneId: scene.id)
                .map { result in
                    ARSceneSourceFileWithData(id: fileId, type: nil, data: result.data!)
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

        return ARSceneSourceFile(id: sourceFile.id, type: sourceFile.type!, localUrl: localFileURL)
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

    internal func getUnresolvedScene(for sceneAlias: String, language: String) -> AnyPublisher<Scene, ARCardsNetworkingServiceError> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.Scene.GetScenesByAliases.Request(sceneAlias: sceneAlias, language: language))
            .tryMap { response in
                switch response.result {
                case .success(let data):
                    guard let scenes = data.success else { throw APIClientError.failure(HTTPResponseStatus(code: data.statusCode, data: response.data)) }
                    guard let scene = scenes.first else { throw APIClientError.failure(HTTPResponseStatus(code: data.statusCode, data: response.data)) }
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
