import FioriSwiftUICore
import Foundation

class FioriARBundle {}

extension Bundle {
    static var fioriAR: Bundle {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: FioriARBundle.self)
        #endif
    }

    func localizedString(forKey key: String) -> String {
        self.localizedString(forKey: key, value: nil, table: nil)
    }
}

extension String {
    var localizedString: String {
        Bundle.fioriAR.localizedString(forKey: self)
    }
}
