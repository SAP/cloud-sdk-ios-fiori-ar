import Combine
import Foundation
import SAPCommon
import SAPFoundation

extension SAPURLSession {
    var extLogger: Logger {
        Logger.shared(named: "FioriAR")
    }
}

extension SAPURLSession {
    /// The DataTaskPublisher class for SAPURLSession.
    class PatchedDataTaskPublisher: Publisher {
        /// The output of this dataTaskPublisher would be a tuple with objects of type Data and URLResponse
        typealias Output = (data: Data, response: URLResponse)
        /// The kind of errors this publisher might publish.
        typealias Failure = Error

        /// The URL request performed by the data task associated with this publisher.
        let urlRequest: URLRequest
        /// The SAPURLSession that performs the data task associated with this publisher.
        let sapurlSession: SAPURLSession

        /// Creates a data task publisher from the provided URL request and SAPURLSession.
        init(urlRequest: URLRequest, sapurlSession: SAPURLSession) {
            self.urlRequest = urlRequest
            self.sapurlSession = sapurlSession
        }

        /// The receive function receives the subscriber S , creates the subscription object and passes on to the subscriber
        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = PatchedDataTaskSubscription(urlRequest: urlRequest, subscriber: subscriber, sapurlSession: sapurlSession)
            self.sapurlSession.extLogger.debug("Calling: receive() on Subscriber with Subscription Object")
            subscriber.receive(subscription: subscription)
        }
    }

    /// The DataTaskSubscription class for SAPURLSession.
    class PatchedDataTaskSubscription<S: Subscriber>: Subscription where S.Input == SAPURLSession.PatchedDataTaskPublisher.Output, S.Failure == Error {
        private let urlRequest: URLRequest
        private var subscriber: S?
        private let urlSession: SAPURLSession

        /// Creates a data task subscription from the provided URL request , SAPURLSession and Subscriber
        init(urlRequest: URLRequest, subscriber: S, sapurlSession: SAPURLSession) {
            self.urlRequest = urlRequest
            self.subscriber = subscriber
            self.urlSession = sapurlSession
        }

        // SAPURLSession Datatask is created and kicked off if the demand is > 0
        func request(_ demand: Subscribers.Demand) {
            if demand > 0 {
                self.urlSession.dataTask(with: self.urlRequest) { [weak self] data, response, error in
                    defer {
                        self?.urlSession.extLogger.debug("In defer method of Subscription.Calling cancel() on the subscription")
                        self?.cancel()
                    }
                    if let data = data, let response = response {
                        self?.urlSession.extLogger.debug("Response and Data received.Calling subscriber receive() with data and response")
                        _ = self?.subscriber?.receive((data: data, response: response))
                        self?.urlSession.extLogger.debug("Sending a completion event with success to the subscriber")
                        self?.subscriber?.receive(completion: .finished)
                    } else if let error = error {
                        self?.urlSession.extLogger.debug("Received an error.Sending a completion event with failure to the subscriber")
                        self?.subscriber?.receive(completion: .failure(error))
                    } else { // PATCH !!!!
                        self?.urlSession.extLogger.debug("Received no data, no response and no error .Sending a completion event with failure to the subscriber")
                        self?.subscriber?.receive(completion: .finished)
                    }
                }.resume()
            }
        }

        /// Cancel the Subscription by setting the subscriber as nil.
        func cancel() {
            self.urlSession.extLogger.debug("In cancel() of Subscription.Setting the subscriber as nil")
            self.subscriber = nil
        }

        deinit {
            self.urlSession.extLogger.debug("Called: deinit on DataTaskSubscription")
        }
    }

    /// The DataTaskSubscriber class for SAPURLSession.
    class PatchedDataTaskSubscriber: Subscriber, Cancellable {
        /// The kind of values this subscriber receives.
        typealias Input = (data: Data, response: URLResponse)
        /// The kind of errors this subscriber might receive.
        typealias Failure = Error

        var subscription: Subscription?
        var sapUrlSession: SAPURLSession?

        init(sapUrlSession: SAPURLSession) {
            self.sapUrlSession = sapUrlSession
        }

        /// Tells the subscriber that it has successfully subscribed to the publisher and may request items.
        func receive(subscription: Subscription) {
            self.subscription = subscription
            self.sapUrlSession?.extLogger.debug("In Subscriber: Received subscription")
            subscription.request(.unlimited)
        }

        /// Tells the subscriber that the publisher has produced an element.
        func receive(_ input: Input) -> Subscribers.Demand {
            self.sapUrlSession?.extLogger.debug("In Subscriber: Received value: \(input)")
            return .none
        }

        /// Tells the subscriber that the publisher has completed publishing, either normally or with an error.
        func receive(completion: Subscribers.Completion<Error>) {
            self.sapUrlSession?.extLogger.debug("In Subscriber: Received completion \(completion)")
            self.cancel()
        }

        /// Cancel the subscription-subscriber relationship.
        func cancel() {
            self.sapUrlSession?.extLogger.debug("In cancel() of Subscriber.Calling subscription.cancel()")
            self.subscription?.cancel()
            self.sapUrlSession?.extLogger.debug("Setting the subscription as nil")
            self.subscription = nil
        }
    }

    // MARK: - DataTaskPublisher

    // extension of SAPURLSession to have a patched version of `dataTaskPublisher`
    // TODO: remove once SAPFoundation.xcframework was fixed
    func _dataTaskPublisher(for urlRequest: URLRequest) -> PatchedDataTaskPublisher {
        self.extLogger.debug("Called: dataTaskPublisherPatched with URLRequest: \(urlRequest.url?.privacyString ?? "N/A")")
        return PatchedDataTaskPublisher(urlRequest: urlRequest, sapurlSession: self)
    }

    private func _dataTaskPublisherPatched(for url: URL) -> PatchedDataTaskPublisher {
        self.extLogger.debug("Called: dataTaskPublisherPatched with URL: \(url.privacyString)")
        let request = URLRequest(url: url)
        return self._dataTaskPublisher(for: request)
    }
}

extension URL {
    var privacyString: String {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return ""
        }

        var result = "\(scheme ?? "http")://"
        if let host = self.host {
            result += host
        }
        if let port = self.port {
            result += ":\(port)"
        }

        let filteredPathComponents: [String] = self.pathComponents.map {
            let startTokens = $0.components(separatedBy: "(")
            return startTokens.count == 2 ? "\(startTokens[0])(***)" : $0
        }
        if !filteredPathComponents.isEmpty {
            let filteredPathComponentsString: String = filteredPathComponents.joined(separator: "/").replacingOccurrences(of: "//", with: "/")
            result += filteredPathComponentsString
        }

        if let queryItems = urlComponents.queryItems {
            let filteredQuery: [String] = queryItems.map { item in
                "\(item.name)=***"
            }
            let filteredQueryString: String = filteredQuery.joined(separator: "&")
            result += "?\(filteredQueryString)"
        }
        return result
    }
}
