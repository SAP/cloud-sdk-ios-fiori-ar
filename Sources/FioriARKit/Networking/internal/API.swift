//
// Generated by SwagGen with template `SwiftSAPURLSession`
// https://github.com/MarcoEidinger/SwagGen/tree/foundation/SwiftSAPURLSession
//

import Foundation

/** Proposal for a service (and its models) to store Augmented Reality (AR) scenes and annotations. The service shall also provide a user interface for admins to allow updating annotationAnchor data. */
internal struct ARService {

    /// Whether to discard any errors when decoding optional properties
    internal static var safeOptionalDecoding = false

    /// Whether to remove invalid elements instead of throwing when decoding arrays
    internal static var safeArrayDecoding = false

    /// Used to encode Dates when uses as string params
    internal static var dateEncodingFormatter = DateFormatter(formatString: "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                                                            locale: Locale(identifier: "en_US_POSIX"),
                                                            calendar: Calendar(identifier: .gregorian))

    internal static let version = "0.0.1"

    internal enum AnnotationAnchor {}
    internal enum File {}
    internal enum Scene {}

    internal enum Server {

        internal static let main = "/augmentedreality/v1"
    }
}
