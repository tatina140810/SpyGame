import UIKit

protocol ThemesPresenterProtocol {
    var selectedThemes: [String] { get }
    func viewDidLoad()
    func selectTheme(named: String)
    func deselectTheme(named: String)
    func selectOnlyCustomTheme(named: String)
    func toggleThemeSelection(for button: UIButton, isSelected: Bool)
    func selectAllThemes(keys: [String])
    func updateCustomThemeButtonTitle(to newTitle: String)
    func deselectAllThemes()
}

final class ThemesPresenter: ThemesPresenterProtocol {
    weak var view: ThemesViewControllerProtocol?
    
    private(set) var selectedThemes: [String] = []
    
    init(view: ThemesViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
    }
    
    func selectTheme(named themeKey: String) {
        if !selectedThemes.contains(themeKey) {
            selectedThemes.append(themeKey)
        }
    }
    
    func deselectTheme(named themeKey: String) {
        selectedThemes.removeAll { $0 == themeKey }
    }
    
    
    func toggleThemeSelection(for button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.layer.borderColor = UIColor.black.cgColor
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    
    func selectAllThemes(keys: [String]) {
        selectedThemes = keys
    }
    func selectOnlyCustomTheme(named themeKey: String) {
        selectedThemes = [themeKey]
        view?.reloadInterface()
    }
    func updateCustomThemeButtonTitle(to newTitle: String) {
        view?.updateCustomButtonTitle(to: newTitle)
    }
    func deselectAllThemes() {
        selectedThemes.removeAll()
    }
    
}
