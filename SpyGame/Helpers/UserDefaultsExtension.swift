import Foundation

struct GameSettings: Codable {
    let playersCount: Int
    let spyCount: Int
    let selectedThemeNames: [String]
    let selectedTime: Int
}

extension UserDefaults {
    
    // MARK: - Game Settings
    private static let gameSettingsKey = "GameSettings"
    
    func saveGameSettings(_ settings: GameSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            set(data, forKey: UserDefaults.gameSettingsKey)
        }
    }
    
    func loadGameSettings() -> GameSettings? {
        guard let data = data(forKey: UserDefaults.gameSettingsKey) else { return nil }
        return try? JSONDecoder().decode(GameSettings.self, from: data)
    }
    
    func clearGameSettings() {
        removeObject(forKey: UserDefaults.gameSettingsKey)
    }
    
    // MARK: - Used Words
    private static let usedWordsKey = "usedWordsKey"
    
    func saveUsedWords(_ words: [String]) {
        set(words, forKey: UserDefaults.usedWordsKey)
    }
    
    func loadUsedWords() -> [String] {
        return array(forKey: UserDefaults.usedWordsKey) as? [String] ?? []
    }
    
    func clearUsedWords() {
        removeObject(forKey: UserDefaults.usedWordsKey)
    }
}
