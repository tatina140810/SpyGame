import UIKit

protocol PlayersSetupProtocol {
    func viewDidLoad()
    func increasePlayers()
    func decreasePlayers()
    func increaseSpies()
    func decreaseSpies()
    func setGameTime(_ seconds: Int)
    func selectTheme(named: String)
    func selectAllThemes(from themes: [Theme])
    func toggleThemeSelection(for button: UIButton, isSelected: Bool)
    func startGame()
    func updateSelectedThemes(_ themes: [String])
    
}

class PlayersSetupPresenter: PlayersSetupProtocol {
    
    weak var view: PlayersSetupViewProtocol?
    
    private var playersCount: Int = 3
    private var spyCount: Int = 1
    private var selectedTime: Int = 60
    private var selectedThemes: Set<String> = []
    
    init(view: PlayersSetupViewProtocol? = nil) {
        self.view = view
        
        loadSavedSettings()
        updateView()
    }
    
    func viewDidLoad() {
        
    }
    
    func increasePlayers() {
        if playersCount < 15 {
            playersCount += 1
            
            view?.updatePlayersCountLabel(playersCount)
        }
    }
    
    func decreasePlayers() {
        if playersCount > 3 {
            playersCount -= 1
            
            view?.updatePlayersCountLabel(playersCount)
        }
    }
    
    func increaseSpies() {
        if spyCount < 3 {
            spyCount += 1
            
            view?.updateSpyCountLabel(spyCount)
        }
    }
    
    func decreaseSpies() {
        if spyCount > 1 {
            spyCount -= 1
            
            view?.updateSpyCountLabel(spyCount)
        }
    }
    
    func setGameTime(_ seconds: Int) {
        selectedTime = seconds
        
    }
    
    func selectTheme(named name: String) {
        if selectedThemes.contains(name) {
            selectedThemes.remove(name)
            
        } else {
            selectedThemes.insert(name)
            
        }
        
    }
    
    func toggleThemeSelection(for button: UIButton, isSelected: Bool) {
        guard let title = button.title(for: .normal) else {
            
            return
        }
        if isSelected {
            selectedThemes.insert(title)
        } else {
            selectedThemes.remove(title)
        }
        
        view?.toggleThemeSelection(for: button, isSelected: isSelected)
    }
    
    func toggleThemeSelection(themeKey: String, isSelected: Bool) {
        if isSelected {
            selectedThemes.insert(themeKey)
        } else {
            selectedThemes.remove(themeKey)
        }
        
    }
    
    func selectAllThemes() {
        selectedThemes = Set(allThemes.map { $0.nameKey })
        if customTheme != nil {
            selectedThemes.insert("theme_custom")
        }
        
        updateView()
    }
    
    func selectAllThemes(from themes: [Theme]) {
        selectedThemes = Set(themes.map { $0.nameKey })
        
        updateView()
    }
    
    func updateSelectedThemes(_ themes: [String]) {
        selectedThemes = Set(themes)
        
        updateView()
    }
    
    func startGame() {
        
        guard !selectedThemes.isEmpty else {
            
            view?.showAlert(message: "select_at_least_one_category".localized)
            return
        }
        
        
        let matchedThemes = allThemes.filter { selectedThemes.contains($0.nameKey) }
        
        let selectedWords = getAllWords(from: Array(selectedThemes))
        
        
        let settings = GameSettings(
            playersCount: playersCount,
            spyCount: spyCount,
            selectedThemeNames: Array(selectedThemes),
            selectedTime: selectedTime
        )
        
        UserDefaults.standard.saveGameSettings(settings)
        
        view?.navigateToGame(playersCount: playersCount,
                             spyCount: spyCount,
                             selectedThemes: matchedThemes,
                             selectedTime: selectedTime,
                             words: selectedWords)
    }
    
    
    private func loadSavedSettings() {
        if let settings = UserDefaults.standard.loadGameSettings() {
            playersCount = settings.playersCount
            spyCount = settings.spyCount
            selectedThemes = Set(settings.selectedThemeNames)
            selectedTime = settings.selectedTime
            
        } else {
        }
    }
    
    private func updateView() {
        
        view?.updatePlayersCountLabel(playersCount)
        view?.updateSpyCountLabel(spyCount)
        view?.highlightedSelectedTime(seconds: selectedTime)
    }
    func getAllWords(from themeKeys: [String]) -> [String] {
        var allWords: [String] = []
        
        for key in themeKeys {
            if key == "theme_custom" {
                if let data = UserDefaults.standard.data(forKey: "custom_theme"),
                   let custom = try? JSONDecoder().decode(Theme.self, from: data) {
                    allWords += custom.words
                }
            } else if let theme = allThemes.first(where: { $0.nameKey == key }) {
                allWords += theme.words
            }
        }
        
        return allWords.shuffled()
    }
}
