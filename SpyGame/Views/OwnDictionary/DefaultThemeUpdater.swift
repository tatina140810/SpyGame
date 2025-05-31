//
//  DefaultThemeUpdater.swift
//  SpyGame
//
//  Created by Tatina Dzhakypbekova on 26/5/2025.
//
import UIKit

protocol ThemeUpdaterProtocol {
    func saveCustomTheme(words: [String])
    func selectCustomTheme(named: String, title: String)
}

final class DefaultThemeUpdater: ThemeUpdaterProtocol {
    func saveCustomTheme(words: [String]) {
        let theme = Theme(nameKey: "theme_custom", words: words)
        if let data = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(data, forKey: "custom_theme")
        }
    }
    
    func selectCustomTheme(named: String, title: String) {
        NotificationCenter.default.post(name: .customThemeUpdated, object: nil, userInfo: ["key": named, "title": title])
    }
}
import Foundation

extension Notification.Name {
    static let customThemeUpdated = Notification.Name("customThemeUpdated")
}

