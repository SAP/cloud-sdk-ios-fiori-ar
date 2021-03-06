//
// Generated by SwagGen with template `SwiftSAPURLSession`
// https://github.com/MarcoEidinger/SwagGen/tree/sap/Swift-SAPURLSession
//

import Foundation

internal class Marker: APIModel {

    public enum Icon: String, Codable, Equatable, CaseIterable {
        case play = "Play"
        case document = "Document"
        case link = "Link"
        case info = "Info"

        func sfSymbolName() -> String {
            switch self {
            case .play:
                return "play"
            case .document:
                return "doc.fill"
            case .link:
                return "link"
            case .info:
                return "info"
            }
        }

        static func create(from sfSymbolName: String?) -> Marker.Icon? {
            guard let sfSymbolName = sfSymbolName else { return nil }
            switch sfSymbolName {
            case "play":
                return Icon.play
            case "doc.fill":
                return Icon.document
            case "link":
                return Icon.link
            case "info":
                return Icon.info
            default:
                return nil
            }
        }
    }

    internal var icon: Icon?

    internal var iconAndroid: String?

    internal var iconIos: String?

    internal init(icon: Icon? = nil, iconAndroid: String? = nil, iconIos: String? = nil) {
        self.icon = icon
        self.iconAndroid = iconAndroid
        self.iconIos = iconIos
    }

    internal required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        icon = try container.decodeIfPresent("icon")
        iconAndroid = try container.decodeIfPresent("icon-android")
        iconIos = try container.decodeIfPresent("icon-ios")
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(icon, forKey: "icon")
        try container.encodeIfPresent(iconAndroid, forKey: "icon-android")
        try container.encodeIfPresent(iconIos, forKey: "icon-ios")
    }

    internal func isEqual(to object: Any?) -> Bool {
      guard let object = object as? Marker else { return false }
      guard self.icon == object.icon else { return false }
      guard self.iconAndroid == object.iconAndroid else { return false }
      guard self.iconIos == object.iconIos else { return false }
      return true
    }

    internal static func == (lhs: Marker, rhs: Marker) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
