import Combine
@testable import FioriAR
import Foundation
import SAPFoundation
import SwiftUI
import XCTest

final class ARCardsNetworkingServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var urlSessionConfiguration: URLSessionConfiguration!
    var sut: ARCardsNetworkingService!
    var testExpectation: XCTestExpectation!

    override func setUp() {
        self.cancellables = []
        NetworkingServiceURLProtocolMock.reset()
        self.urlSessionConfiguration = URLSessionConfiguration.ephemeral
        self.urlSessionConfiguration.protocolClasses = [NetworkingServiceURLProtocolMock.self]
        self.sut = ARCardsNetworkingService(sapURLSession: SAPURLSession(configuration: self.urlSessionConfiguration), baseURL: "Test")
        self.testExpectation = expectation(description: "testExpectation")
    }

    func testGetSceneById() throws {
        var loadedScene: ARScene?

        NetworkingServiceURLProtocolMock.requestHandler = { request in
            guard let url = request.url else { fatalError() }
            switch url.absoluteString {
            case _ where url.absoluteString.contains("/augmentedreality/v1/runtime/scene/20110991?language"):
                return (HTTPURLResponse(url: url, statusCode: 200), try XCTUnwrap(Bundle.module.getTextContent(forResource: "GET_scene")))
            case _ where url.absoluteString.contains("/augmentedreality/v1/runtime/scene/20110991/file"):
                return (HTTPURLResponse(url: url, statusCode: 200), try XCTUnwrap(Bundle.module.getBinaryContent(of: "qrImage")))
            default:
                return nil
            }
        }

        self.sut.getScene(.id(20110991))
            .sink { completion in
                switch completion {
                case .finished:

                    self.testExpectation.fulfill()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { scene in
                loadedScene = scene
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 0.1, handler: nil)

        XCTAssertEqual(loadedScene?.sceneId, 20110991)
        XCTAssertEqual(NetworkingServiceURLProtocolMock.receivedRequests.count, 2)
    }

    func testGetSceneByAlias() throws {
        var loadedScene: ARScene?

        NetworkingServiceURLProtocolMock.requestHandler = { request in
            guard let url = request.url else { return nil }
            switch url.absoluteString {
            case _ where url.absoluteString.contains("/augmentedreality/v1/runtime/scene/findByAlias?language=en&sceneAlias=myOwnAlias"):
                return (HTTPURLResponse(url: url, statusCode: 200), try XCTUnwrap(Bundle.module.getTextContent(forResource: "GET_scene_findById")))
            case _ where url.absoluteString.contains("/augmentedreality/v1/runtime/scene/20110991/file"):
                return (HTTPURLResponse(url: url, statusCode: 200), try XCTUnwrap(Bundle.module.getBinaryContent(of: "qrImage")))
            default:
                return nil
            }
        }

        self.sut.getScene(.alias("myOwnAlias"))
            .sink { completion in
                switch completion {
                case .finished:
                    self.testExpectation.fulfill()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { scene in
                loadedScene = scene
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 0.5, handler: nil)

        XCTAssertEqual(loadedScene?.sceneId, 20110991)
        XCTAssertEqual(NetworkingServiceURLProtocolMock.receivedRequests.count, 2)
    }

    func testCreateScene() throws {
        var createdSceneId: Int?
        let imageData = try XCTUnwrap(Bundle.module.getBinaryContent(of: "qrImage"))
        let cardToBeCreated = CodableCardItem(id: "123", title_: "MyCardTitle", subtitle_: "MyCardSubtitle", detailImage_: nil, image: .init(id: "MyCardImage", data: imageData), actionText_: nil, actionContentURL_: nil, icon_: nil, position_: SIMD3<Float>.optional(x: 1, y: 1, z: 1))
        let cardsToBeCreated: [CodableCardItem] = [cardToBeCreated]

        NetworkingServiceURLProtocolMock.requestHandler = { request in
            guard let url = request.url, url.absoluteString.hasSuffix("/augmentedreality/v1/runtime/scene") else { return nil }
            return (HTTPURLResponse(url: url, statusCode: 201), try XCTUnwrap(Bundle.module.getTextContent(forResource: "GET_scene")))
        }

        self.sut.createScene(identifiedBy: imageData, anchorImagePhysicalWidth: 3.0, anchorImageFileName: "myImageAnchor", cards: cardsToBeCreated, sceneAlias: "customAlias")
            .sink { completion in
                guard case .finished = completion else { return }
                self.testExpectation.fulfill()
            } receiveValue: { sceneId in
                createdSceneId = sceneId
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 0.1, handler: nil)

        XCTAssertNotNil(createdSceneId)
        XCTAssertEqual(NetworkingServiceURLProtocolMock.receivedRequests.count, 1)
    }

    func testUpdateScene() throws {
        var receivedValue: String?

        NetworkingServiceURLProtocolMock.requestHandler = { request in
            (HTTPURLResponse(url: request.url!, statusCode: 200), "Update success.".data(using: .utf8)!)
        }

        self.sut.updateScene(123, identifiedBy: nil, anchorImagePhysicalWidth: 2.0, updateCards: [], deleteCards: [])
            .sink { completion in
                guard case .finished = completion else { return }
                self.testExpectation.fulfill()
            } receiveValue: { resultString in
                receivedValue = resultString
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 0.1, handler: nil)

        XCTAssertEqual(receivedValue, "Update success.")
        XCTAssertEqual(NetworkingServiceURLProtocolMock.receivedRequests.count, 1)
    }

    func testUpdateScene404Error() throws {
        var receivedError: Error?

        NetworkingServiceURLProtocolMock.requestHandler = { request in
            (HTTPURLResponse(url: request.url!, statusCode: 404), "Not found".data(using: .utf8)!)
        }

        self.sut.updateScene(123, identifiedBy: nil, anchorImagePhysicalWidth: 2.0, updateCards: [], deleteCards: [])
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                receivedError = error
                self.testExpectation.fulfill()
            } receiveValue: { _ in
                ()
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 0.1, handler: nil)

        let error = try XCTUnwrap(receivedError)
        XCTAssertEqual(error.localizedDescription, "Not found")
        guard case .failure(let httpError) = error as? ARCardsNetworkingServiceError else {
            XCTFail("Expected failure, but was \(error)")
            return
        }
        XCTAssertEqual(httpError.code, 404)
        XCTAssertEqual(httpError.description, "Not found")
    }

    func testUpdateSceneDeleteCard() throws {
        var receivedValue: String?

        NetworkingServiceURLProtocolMock.requestHandler = { request in
            guard let url = request.url else { return nil }
            if url.absoluteString.hasSuffix("/augmentedreality/v1/runtime/scene/123/annotationAnchor/cardIdToDelete") {
                return (HTTPURLResponse(url: url, statusCode: 204), "".data(using: .utf8)!)
            } else {
                return (HTTPURLResponse(url: url, statusCode: 200), "Update success.".data(using: .utf8)!)
            }
        }

        self.sut.updateScene(123, identifiedBy: nil, anchorImagePhysicalWidth: nil, updateCards: [], deleteCards: ["cardIdToDelete"])
            .sink { completion in
                guard case .finished = completion else { return }
                self.testExpectation.fulfill()
            } receiveValue: { resultString in
                receivedValue = resultString
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 0.1, handler: nil)

        XCTAssertEqual(receivedValue, "Update success.")
        XCTAssertEqual(NetworkingServiceURLProtocolMock.receivedRequests.count, 2)
    }
}

// MARK: Utilities

class NetworkingServiceURLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data)?)?

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
            guard let (response, data) = try handler(request) else {
                client?.urlProtocolDidFinishLoading(self)
                return
            }
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
