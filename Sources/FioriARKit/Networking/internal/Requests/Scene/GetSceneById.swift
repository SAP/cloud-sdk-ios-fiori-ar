//
// Generated by SwagGen with template `SwiftSAPURLSession`
// https://github.com/MarcoEidinger/SwagGen/tree/sap/Swift-SAPURLSession
//

import Foundation

extension ARService.Scene {

    /**
    Find scene by ID

    Returns a single scene
    */
    internal enum GetSceneById {

        internal static let service = APIService<Response>(id: "getSceneById", tag: "scene", method: "GET", path: "/scene/{sceneId}", hasBody: false)

        internal final class Request: APIRequest<Response> {

            internal struct Options {

                /** ID of scene to return */
                internal var sceneId: String

                /** Language */
                internal var language: String?

                internal init(sceneId: String, language: String? = nil) {
                    self.sceneId = sceneId
                    self.language = language
                }
            }

            internal var options: Options

            internal init(options: Options) {
                self.options = options
                super.init(service: GetSceneById.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            internal convenience init(sceneId: String, language: String? = nil) {
                let options = Options(sceneId: sceneId, language: language)
                self.init(options: options)
            }

            internal override var path: String {
                return super.path.replacingOccurrences(of: "{" + "sceneId" + "}", with: "\(self.options.sceneId)")
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
            internal typealias SuccessType = Scene

            /** successful operation */
            case status200(Scene)

            /** Business user is not authenticated */
            case status401

            /** Scene not found */
            case status404

            /** Invalid request path or method */
            case status405

            /** Can't provide required language scene */
            case status406(SupportLanguage)

            /** Server internal error */
            case status500

            internal var success: Scene? {
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
            internal var responseResult: APIResponseResult<Scene, SupportLanguage> {
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
                case 200: self = try .status200(decoder.decode(Scene.self, from: data))
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
