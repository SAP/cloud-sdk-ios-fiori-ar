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

    internal func getUnresolvedAnnotationAnchors(for sceneId: String, completionHandler: @escaping (Result<[AnnotationAnchor], ARCardsNetworkingServiceError>) -> Void) {
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

    public func getImage(fileId id: String, completionHandler: @escaping (Result<UIImage?, ARCardsNetworkingServiceError>) -> Void) {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        api.makeRequest(ARService.File.GetFileById.Request(fileId: id)) { response in
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

    public func getImage(fileId id: String) -> AnyPublisher<FileImage, Error> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.File.GetFileById.Request(fileId: id))
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

    internal func getFile(fileId id: String) -> AnyPublisher<FileData, Error> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.File.GetFileById.Request(fileId: id))
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
            return self.getFile(fileId: fileId)
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
    public func getCards(for sceneId: String, language: String = NSLocale.autoupdatingCurrent.languageCode ?? NSLocale.preferredLanguages.first ?? "en") -> AnyPublisher<[DecodableCardItem], Error> {
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
                self.getImage(fileId: fileId)
                    .eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()

        return Publishers.Zip(scenePublisher, filesPublisher)
            .flatMap { scene, files -> AnyPublisher<[DecodableCardItem], Error> in

                var cards: [DecodableCardItem] = []

                // resolve cards, i.e. merge image data into card (if available)
                for anchor in scene.annotationAnchors ?? [] {
                    var image: Image?
                    if let fileId = anchor.card.image, let file = files.first(where: { $0.id == fileId }), let uiimage = file.image {
                        image = Image(uiImage: uiimage)
                    }

                    let card = DecodableCardItem(
                        id: anchor.id ?? UUID().uuidString,
                        title_: anchor.card.title ?? "",
                        descriptionText_: anchor.card.description ?? "",
                        detailImage_: image,
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

    public func getScene(for sceneId: String, language: String = NSLocale.autoupdatingCurrent.languageCode ?? NSLocale.preferredLanguages.first ?? "en") -> AnyPublisher<ARScene, Error> {
        let scenePublisher = self.getUnresolvedScene(for: sceneId, language: language)
            .mapError { $0 as Error }
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
                self.getImage(fileId: fileId)
                    .eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()

        return Publishers.Zip3(scenePublisher, imagesFilesPublisher, sourceFilePublisher)
            .flatMap { scene, imageFiles, sourceFile -> AnyPublisher<ARScene, Error> in

                var cards: [DecodableCardItem] = []

                // resolve cards, i.e. merge image data into card (if available)
                for anchor in scene.annotationAnchors ?? [] {
                    var image: Image?
                    if let fileId = anchor.card.image, let file = imageFiles.first(where: { $0.id == fileId }), let uiimage = file.image {
                        image = Image(uiImage: uiimage)
                    }

                    let card = DecodableCardItem(
                        id: anchor.id ?? UUID().uuidString,
                        title_: anchor.card.title ?? "",
                        descriptionText_: anchor.card.description ?? "",
                        detailImage_: image,
                        actionText_: anchor.card.actionText,
                        icon_: nil
                    )
                    cards.append(card)
                }

                var sourceFileUrl: ARSceneSourceFile?
                if let f = sourceFile {
                    sourceFileUrl = try! self.save(sourceFile: f)
                }

                let arScene = ARScene(sceneId: scene.id, sourceFile: sourceFileUrl, annotationAnchorImage: Image("qrImage"), annotationAnchorImagePysicalWidth: scene.referenceAnchor?.physicalWidth ?? 0.1, cards: cards)

                return Just(arScene)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
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

        return ARSceneSourceFile(id: sourceFile.id, type: sourceFile.type, localUrl: localFileURL)
    }

    internal func getUnresolvedScene(for sceneId: String, language: String) -> AnyPublisher<Scene, ARCardsNetworkingServiceError> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.Scene.GetSceneById.Request(sceneId: sceneId, language: language))
            .tryMap { response in
                switch response.result {
                case .success(let data):
                    guard data.successful, let scene = data.success else {
                        throw APIClientError.unknownError(ARCardsNetworkingServiceError.notFound)
                    }
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

    internal func getUnresolvedAnnotationAnchors(for sceneId: String, language: String) -> AnyPublisher<[AnnotationAnchor], ARCardsNetworkingServiceError> {
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
        }
    }
}
