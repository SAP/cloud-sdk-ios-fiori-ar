//
// Generated by SwagGen with template `SwiftSAPURLSession`
// https://github.com/MarcoEidinger/SwagGen/tree/sap/Swift-SAPURLSession
//

import Foundation

extension ARService.AnnotationAnchor {

    /** Get an existing annotation */
    internal enum GetAnnotation {

        internal static let service = APIService<Response>(id: "getAnnotation", tag: "annotationAnchor", method: "GET", path: "/scene/{sceneId}/annotationAnchor/{id}", hasBody: false)

        internal final class Request: APIRequest<Response> {

            internal struct Options {

                /** ID of scene */
                internal var sceneId: String

                /** ID of annotation anchor */
                internal var id: String

                /** Language */
                internal var language: String?

                internal init(sceneId: String, id: String, language: String? = nil) {
                    self.sceneId = sceneId
                    self.id = id
                    self.language = language
                }
            }

            internal var options: Options

            internal init(options: Options) {
                self.options = options
                super.init(service: GetAnnotation.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            internal convenience init(sceneId: String, id: String, language: String? = nil) {
                let options = Options(sceneId: sceneId, id: id, language: language)
                self.init(options: options)
            }

            internal override var path: String {
                return super.path.replacingOccurrences(of: "{" + "sceneId" + "}", with: "\(self.options.sceneId)").replacingOccurrences(of: "{" + "id" + "}", with: "\(self.options.id)")
            }

            internal override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                if let language = options.language {
                  params["language"] = language
                }
                return params
            }
        }

        internal enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            internal typealias SuccessType = AnnotationAnchor

            /** successful operation */
            case status200(AnnotationAnchor)

            /** Business user is not authenticated */
            case status401

            /** AnnotationAnchor not found */
            case status404

            /** Invalid request path or method */
            case status405

            /** Can't provide required language card */
            case status406(SupportLanguage)

            /** Server internal error */
            case status500

            internal var success: AnnotationAnchor? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            internal var failure: SupportLanguage? {
                switch self {
                case .status406(let response): return response
                default: return nil
                }
            }

            /// either success or failure value. Success is anything in the 200..<300 status code range
            internal var responseResult: APIResponseResult<AnnotationAnchor, SupportLanguage> {
                if let successValue = success {
                    return .success(successValue)
                } else if let failureValue = failure {
                    return .failure(failureValue)
                } else {
                    fatalError("Response does not have success or failure response")
                }
            }

            internal var response: Any {
                switch self {
                case .status200(let response): return response
                case .status406(let response): return response
                default: return ()
                }
            }

            internal var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status401: return 401
                case .status404: return 404
                case .status405: return 405
                case .status406: return 406
                case .status500: return 500
                }
            }

            internal var successful: Bool {
                switch self {
                case .status200: return true
                case .status401: return false
                case .status404: return false
                case .status405: return false
                case .status406: return false
                case .status500: return false
                }
            }

            internal init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(AnnotationAnchor.self, from: data))
                case 401: self = .status401
                case 404: self = .status404
                case 405: self = .status405
                case 406: self = try .status406(decoder.decode(SupportLanguage.self, from: data))
                case 500: self = .status500
                default: throw APIClientError.unexpectedStatusCode(statusCode: statusCode, data: data)
                }
            }

            internal var description: String {
                return "\(statusCode) \(successful ? "success" : "failure")"
            }

            internal var debugDescription: String {
                var string = description
                let responseString = "\(response)"
                if responseString != "()" {
                    string += "\n\(responseString)"
                }
                return string
            }
        }
    }
}
