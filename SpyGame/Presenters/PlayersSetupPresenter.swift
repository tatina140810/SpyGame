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
    
    
    init(view: PlayersSetupViewProtocol? = nil) {
        self.view = view
        loadSavedSettings()
        updateView()
    }
    private var playersCount: Int = 3
    private var spyCount: Int = 1
    private var selectedThemes: [String] = []
    private var selectedTime: Int = 60
    
    
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
    
    func selectTheme(named theme: String) {
        if selectedThemes.contains(theme) {
            selectedThemes.removeAll { $0 == theme }
        } else {
            selectedThemes.append(theme)
        }
    }
    
    func selectAllThemes(from themes: [Theme]) {
        selectedThemes = themes.map { $0.nameKey }
    }
    
    private func updateView() {
        view?.updatePlayersCountLabel(playersCount)
        view?.updateSpyCountLabel(spyCount)
        view?.highlightSelectedThemes(named: selectedThemes)
    }
    
    func toggleThemeSelection(for button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = .white
            button.setTitleColor(.darkGreen, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
        }
    }
    func setGameTime(_ seconds: Int) {
        selectedTime = seconds
    }
    
    func startGame() {
        let selectedThemesModels = allThemes.filter { selectedThemes.contains($0.nameKey) }
        
        if selectedThemesModels.isEmpty {
            view?.showAlert(message: "select_at_least_one_category".localized)
            return
        }
        
        if selectedTime == 0 {
            view?.showAlert(message: "Выберите время для игры.")
            return
        }
        
        let settings = GameSettings(
            playersCount: playersCount,
            spyCount: spyCount,
            selectedThemeNames: selectedThemes,
            selectedTime: selectedTime
        )
        UserDefaults.standard.saveGameSettings(settings)
        
        view?.navigateToGame(playersCount: playersCount,
                             spyCount: spyCount,
                             selectedThemes: selectedThemesModels,
                             selectedTime: selectedTime)
    }
    private func loadSavedSettings() {
        if let saved = UserDefaults.standard.loadGameSettings() {
            playersCount = saved.playersCount
            spyCount = saved.spyCount
            selectedThemes = saved.selectedThemeNames
            print(selectedThemes)
            selectedTime = saved.selectedTime
            print (selectedTime)
        }
    }
    
    
}
