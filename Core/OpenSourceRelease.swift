import Foundation

enum OpenSourceRelease {
    static let donationURL = URL(string: "https://github.com/sponsors/MrSaneApps")!

    static func activate() {
        UserDefaults.standard.set(true, forKey: "SANEAPPS_OPEN_SOURCE")
    }
}
