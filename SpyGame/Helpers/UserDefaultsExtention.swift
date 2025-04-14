//
//  UserDefaultsExtention.swift
//  SpyGame
//
//  Created by Tatina Dzhakypbekova on 13/4/2025.
//

import Foundation

struct GameSettings: Codable {
    let playersCount: Int
    let spyCount: Int
    let selectedThemeNames: [String]
    let selectedTime: Int
}
extension UserDefaults {
    private static let gameSettingsKey = "GameSettings"

    func saveGameSettings(_ settings: GameSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            set(data, forKey: UserDefaults.gameSettingsKey)
        }
    }

    func loadGameSettings() -> GameSettings? {
        if let data = data(forKey: UserDefaults.gameSettingsKey),
           let settings = try? JSONDecoder().decode(GameSettings.self, from: data) {
            return settings
        }
        return nil
    }

    func clearGameSettings() {
        removeObject(forKey: UserDefaults.gameSettingsKey)
    }
}
