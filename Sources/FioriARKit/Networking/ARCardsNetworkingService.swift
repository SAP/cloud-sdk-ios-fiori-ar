import Combine
import SAPFoundation
import SwiftUI

public enum ARCardsNetworkingServiceError: Error {
    case serverError(Error)
    case networkError(Error)
    case unknownError(Error)
}

public typealias FileImage = (id: String, image: UIImage?)

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
        api.makeRequest(ARService.Scene.GetSceneById.Request(sceneId: sceneId, locale: nil)) { response in
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

    // MARK: getCards - Combine

    public func getCards(for sceneId: String) -> AnyPublisher<[DecodableCardItem], Error> {
        let annotationAnchorsPublisher = self.getUnresolvedAnnotationAnchors(for: sceneId)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()

        let filesPublisher = annotationAnchorsPublisher
            .mapError { $0 as Error }
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

        return Publishers.Zip(annotationAnchorsPublisher, filesPublisher)
            .flatMap { annotationAnchors, files -> AnyPublisher<[DecodableCardItem], Error> in

                var cards: [DecodableCardItem] = []

                // resolve cards, i.e. merge image data into card (if available)
                for anchor in annotationAnchors {
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

    internal func getUnresolvedAnnotationAnchors(for sceneId: String) -> AnyPublisher<[AnnotationAnchor], ARCardsNetworkingServiceError> {
        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
        return api.makeRequest(ARService.Scene.GetSceneById.Request(sceneId: sceneId, locale: nil))
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

    //    private func getAllScenesCount(completionHandler: @escaping (Result<Int, ARCardsNetworkingServiceError>) -> Void) {
    //        let api = APIClient(baseURL: self.baseURL, sapURLSession: self.sapURLSession)
    //        api.makeRequest(ARService.Scene.GetScenes.Request()) { response in
    //            switch response.result {
    //            case .success(let data):
    //                var scenes: [Scene] = []
    //                if data.successful {
    //                    scenes = data.success ?? []
    //                }
    //                completionHandler(.success(scenes.count))
    //            case .failure(let apiClientError):
    //                completionHandler(.failure(self.sdkClientError(from: apiClientError)))
    //            }
    //        }
    //    }
}
