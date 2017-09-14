import Foundation

enum BuildConfig {
    case debug
    case release
    
    static var active: BuildConfig {
        #if DEBUG
            return .debug
        #else
            return .release
        #endif
    }
}
