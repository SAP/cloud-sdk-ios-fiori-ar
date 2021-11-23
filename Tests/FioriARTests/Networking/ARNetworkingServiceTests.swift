import Combine
@testable import FioriAR
import Foundation
import SAPFoundation
import SwiftUI
import XCTest

final class ARCardsNetworkingServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var urlSessionConfiguration: URLSessionConfiguration!

    override func setUp() {
        self.cancellables = []
        self.urlSessionConfiguration = URLSessionConfiguration.ephemeral
        NetworkingServiceURLProtocolMock.reset()
    }

    func testGetSceneById() throws {
        // Mocking logic
        self.urlSessionConfiguration.protocolClasses = [NetworkingServiceURLProtocolMock.self]
        NetworkingServiceURLProtocolMock.requestHandler = { request in
            guard let url = request.url else { fatalError() }
            switch url.absoluteString {
            case _ where url.absoluteString.contains("/augmentedreality/v1/runtime/scene/20110991?language"):
                return (HTTPURLResponse(url: url, statusCode: 200), try XCTUnwrap(Bundle.module.getTextContent(forResource: "GET_scene")))
            case _ where url.absoluteString.contains("/augmentedreality/v1/runtime/scene/20110991/file"):
                return (HTTPURLResponse(url: url, statusCode: 200), try XCTUnwrap(Bundle.module.getBinaryContent(of: "qrImage")))
            default:
                fatalError()
            }
        }

        let networkingService = ARCardsNetworkingService(sapURLSession: SAPURLSession(configuration: self.urlSessionConfiguration), baseURL: "Test")
        let sceneLoaded = expectation(description: "sceneLoaded")

        var loadedScene: ARScene?

        // CUT
        networkingService.getScene(.id(20110991))
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertEqual(loadedScene?.sceneId, 20110991)
                    XCTAssertEqual(NetworkingServiceURLProtocolMock.receivedRequests.count, 2)
                    sceneLoaded.fulfill()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { scene in
                loadedScene = scene
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testGetSceneByAlias() throws {
        // Mocking logic
        self.urlSessionConfiguration.protocolClasses = [NetworkingServiceURLProtocolMock.self]
        NetworkingServiceURLProtocolMock.requestHandler = { request in
            guard let url = request.url else { fatalError() }
            switch url.absoluteString {
            case _ where url.absoluteString.contains("/augmentedreality/v1/runtime/scene/findByAlias?language=en&sceneAlias=myOwnAlias"):
                return (HTTPURLResponse(url: url, statusCode: 200), try XCTUnwrap(Bundle.module.getTextContent(forResource: "GET_scene_findById")))
            case _ where url.absoluteString.contains("/augmentedreality/v1/runtime/scene/20110991/file"):
                return (HTTPURLResponse(url: url, statusCode: 200), try XCTUnwrap(Bundle.module.getBinaryContent(of: "qrImage")))
            default:
                fatalError()
            }
        }

        let networkingService = ARCardsNetworkingService(sapURLSession: SAPURLSession(configuration: self.urlSessionConfiguration), baseURL: "Test")
        let sceneLoaded = expectation(description: "sceneLoaded")

        var loadedScene: ARScene?

        // CUT
        networkingService.getScene(.alias("myOwnAlias"))
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertEqual(loadedScene?.sceneId, 20110991)
                    XCTAssertEqual(NetworkingServiceURLProtocolMock.receivedRequests.count, 2)
                    sceneLoaded.fulfill()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { scene in
                loadedScene = scene
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCreateScene() throws {
        // Mocking logic
        self.urlSessionConfiguration.protocolClasses = [NetworkingServiceURLProtocolMock.self]
        NetworkingServiceURLProtocolMock.requestHandler = { request in
            if request.httpMethod == "POST", let url = request.url, url.absoluteString.hasSuffix("/augmentedreality/v1/runtime/scene") {
                return (HTTPURLResponse(url: url, statusCode: 201), try XCTUnwrap(Bundle.module.getTextContent(forResource: "GET_scene")))
            } else {
                fatalError()
            }
        }

        let networkingService = ARCardsNetworkingService(sapURLSession: SAPURLSession(configuration: self.urlSessionConfiguration), baseURL: "Test")
        let sceneCreated = expectation(description: "sceneCreated")

        var createdSceneId: Int?

        let imageData = try XCTUnwrap(Bundle.module.getBinaryContent(of: "qrImage"))
        let card = CodableCardItem(id: "123", title_: "MyCardTitle", subtitle_: "MyCardSubtitle", detailImage_: nil, image: .init(id: "MyCardImage", data: imageData), actionText_: nil, actionContentURL_: nil, icon_: nil, position_: SIMD3<Float>.optional(x: 1, y: 1, z: 1))
        let cards: [CodableCardItem] = [card]

        // CUT
        networkingService.createScene(identifiedBy: imageData, anchorImagePhysicalWidth: 3.0, anchorImageFileName: "myImageAnchor", cards: cards, sceneAlias: "customAlias")
            .sink { completion in
                switch completion {
                case .finished:
                    XCTAssertNotNil(createdSceneId)
                    XCTAssertEqual(NetworkingServiceURLProtocolMock.receivedRequests.count, 1)
                    sceneCreated.fulfill()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { sceneId in
                createdSceneId = sceneId
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 1, handler: nil)
    }
}

// MARK: Utilities

class NetworkingServiceURLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    static var receivedRequests: [URLRequest] = []

    static func reset() {
        NetworkingServiceURLProtocolMock.requestHandler = nil
        NetworkingServiceURLProtocolMock.receivedRequests = []
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        NetworkingServiceURLProtocolMock.receivedRequests.append(request)
        guard let handler = NetworkingServiceURLProtocolMock.requestHandler else {
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

extension HTTPURLResponse {
    convenience init(url: URL, statusCode: Int) {
        self.init(url: url, statusCode: statusCode, httpVersion: "2.0", headerFields: nil)!
    }
}

private extension Bundle {
    func getTextContent(forResource resourceName: String, withExtension type: String = "json") -> Data? {
        guard let url = Bundle.module.url(forResource: resourceName, withExtension: type) else { return nil }
        do {
            let stringContent = try String(contentsOf: url)
            return stringContent.data(using: .utf8)
        } catch {
            return nil
        }
    }

    func getBinaryContent(of resourceName: String, ofType type: String = "png") -> Data? {
        guard let url = Bundle.module.url(forResource: resourceName, withExtension: type) else { return nil }
        do {
            return try Data(contentsOf: url)
        } catch {
            return nil
        }
    }
}
