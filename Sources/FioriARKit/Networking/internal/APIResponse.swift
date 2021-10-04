//
// Generated by SwagGen with template `SwiftSAPURLSession`
// https://github.com/MarcoEidinger/SwagGen/tree/sap/Swift-SAPURLSession
//

import Foundation

internal protocol APIResponseValue: CustomDebugStringConvertible, CustomStringConvertible {
    associatedtype SuccessType
    var statusCode: Int { get }
    var successful: Bool { get }
    var response: Any { get }
    init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws
    var success: SuccessType? { get }
}

internal enum APIResponseResult<SuccessType, FailureType>: CustomStringConvertible, CustomDebugStringConvertible {
    case success(SuccessType)
    case failure(FailureType)

    internal var value: Any {
        switch self {
        case .success(let value): return value
        case .failure(let value): return value
        }
    }

    internal var successful: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    internal var description: String {
        return "\(successful ? "success" : "failure")"
    }

    internal var debugDescription: String {
        return "\(description):\n\(value)"
    }
}

internal struct APIResponse<T: APIResponseValue> {

    /// The APIRequest used for this response
    internal let request: APIRequest<T>

    /// The result of the response .
    internal let result: APIResult<T>

    /// The URL request sent to the server.
    internal let urlRequest: URLRequest?

    /// The server's response to the URL request.
    internal let urlResponse: HTTPURLResponse?

    /// The data returned by the server.
    internal let data: Data?

    /// The timeline of the complete lifecycle of the request.
    internal let metrics: URLSessionTaskMetrics?

    init(request: APIRequest<T>, result: APIResult<T>, urlRequest: URLRequest? = nil, urlResponse: HTTPURLResponse? = nil, data: Data? = nil, metrics: URLSessionTaskMetrics? = nil) {
        self.request = request
        self.result = result
        self.urlRequest = urlRequest
        self.urlResponse = urlResponse
        self.data = data
        self.metrics = metrics
    }
}

extension APIResponse: CustomStringConvertible, CustomDebugStringConvertible {

    internal var description:String {
        var string = "\(request)"

        switch result {
        case .success(let value):
            string += " returned \(value.statusCode)"
            let responseString = "\(type(of: value.response))"
            if responseString != "()" {
                string += ": \(responseString)"
            }
        case .failure(let error): string += " failed: \(error)"
        }
        return string
    }

    internal var debugDescription: String {
        var string = description
        if let response = try? result.get().response {
          if let debugStringConvertible = response as? CustomDebugStringConvertible {
              string += "\n\(debugStringConvertible.debugDescription)"
          }
        }
        return string
    }
}
