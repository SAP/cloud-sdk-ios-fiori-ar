//
// Generated by SwagGen with template `SwiftSAPURLSession`
// https://github.com/MarcoEidinger/SwagGen/tree/sap/Swift-SAPURLSession
//

import Foundation

internal class SupportLanguage: APIModel {

    internal var languages: [String]?

    internal var message: String?

    internal init(languages: [String]? = nil, message: String? = nil) {
        self.languages = languages
        self.message = message
    }

    internal required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        languages = try container.decodeArrayIfPresent("languages")
        message = try container.decodeIfPresent("message")
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(languages, forKey: "languages")
        try container.encodeIfPresent(message, forKey: "message")
    }

    internal func isEqual(to object: Any?) -> Bool {
      guard let object = object as? SupportLanguage else { return false }
      guard self.languages == object.languages else { return false }
      guard self.message == object.message else { return false }
      return true
    }

    internal static func == (lhs: SupportLanguage, rhs: SupportLanguage) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
