import UIKit

protocol PlayersSetupProtocol {
    func increasePlayers()
    func decreasePlayers()
    func increaseSpies()
    func decreaseSpies()
    func setGameTime(_ seconds: Int)
    func selectTheme(named: String)
    func selectAllThemes(from themes: [Theme])
    func toggleThemeSelection(for button: UIButton, isSelected: Bool)
    func startGame()
}

class PlayersSetupPresenter: PlayersSetupProtocol {
    
    weak var view: PlayersSetupViewProtocol?
    
    private var playersCount: Int = 3
    private var spyCount: Int = 1
    private var selectedThemes: Set<String> = []
    private var selectedTime: Int = 60
    
    init(view: PlayersSetupViewProtocol? = nil) {
        self.view = view
        loadSavedSettings()
        updateView()
    }
    
    // MARK: - Player Count
    
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
    
    // MARK: - Spy Count
    
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
    
    // MARK: - Theme Selection
    
    func selectTheme(named name: String) {
        if selectedThemes.contains(name) {
            selectedThemes.remove(name)
        } else {
            selectedThemes.insert(name)
        }
    }
    
    func selectAllThemes(from themes: [Theme]) {
        selectedThemes = Set(themes.map { $0.nameKey })
        view?.highlightSelectedThemes(named: Array(selectedThemes))
    }
    
    func toggleThemeSelection(for button: UIButton, isSelected: Bool) {
        guard let title = button.title(for: .normal) else { return }
        
        if isSelected {
            selectedThemes.insert(title)
        } else {
            selectedThemes.remove(title)
        }
        
        view?.toggleThemeSelection(for: button, isSelected: isSelected)
    }
    
    // MARK: - Time
    
    func setGameTime(_ seconds: Int) {
        selectedTime = seconds
    }
    
    // MARK: - Start Game
    
    func startGame() {
        guard !selectedThemes.isEmpty else {
            view?.showAlert(message: "select_at_least_one_category".localized)
            return
        }
        
        let matchedThemes = allThemes.filter { selectedThemes.contains($0.nameKey) }
        
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
                             selectedTime: selectedTime)
    }
    
    // MARK: - Private Helpers
    
    private func updateView() {
        view?.updatePlayersCountLabel(playersCount)
        view?.updateSpyCountLabel(spyCount)
        view?.highlightSelectedThemes(named: Array(selectedThemes))
        view?.highlightedSelectedTime(seconds: selectedTime)
    }
    
    private func loadSavedSettings() {
        if let settings = UserDefaults.standard.loadGameSettings() {
            playersCount = settings.playersCount
            spyCount = settings.spyCount
            selectedThemes = Set(settings.selectedThemeNames)
            selectedTime = settings.selectedTime
            
        }
    }
    
}
