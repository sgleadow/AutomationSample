import Foundation

protocol ToggleType {
    var enabled: Bool { get }
}

struct Toggle: ToggleType {
    let enabled: Bool
    
    init(_ enabledConfigs: [BuildConfig], buildConfig: BuildConfig = BuildConfig.active) {
        enabled = enabledConfigs.contains(buildConfig)
    }
}
