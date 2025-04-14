import UIKit
import Foundation

protocol LanguagePresenterProtocol {
    func viewDidLoad()
    func didSelectLanguage(_ language: Language)
    func applySelectedLanguage()
}
class LanguagePresenter: LanguagePresenterProtocol {
    
    weak var view: LanguageViewProtocol?
    private(set) var selectedLanguage: Language
    
    init(view: LanguageViewProtocol) {
        self.view = view
        self.selectedLanguage = LanguageManager.shared.currentLanguage
    }
    
    func viewDidLoad() {
        view?.updateLanguageButtonStyles(selected: selectedLanguage)
    }
    
    func didSelectLanguage(_ language: Language) {
        selectedLanguage = language
        view?.updateLanguageButtonStyles(selected: selectedLanguage)
    }
    
    func applySelectedLanguage() {
        LanguageManager.shared.currentLanguage = selectedLanguage
        view?.reloadInterface()
    }
}
