import Foundation

enum Language: String {
    case english = "en"
    case russian = "ru"
    case kyrgyz = "ky-KG"
}

class LanguageManager {
    static let shared = LanguageManager()
    
    private let languageKey = "selectedLanguage"
    
    var currentLanguage: Language {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: languageKey),
               let language = Language(rawValue: rawValue) {
                return language
            }
            return .english
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
        }
    }
}
