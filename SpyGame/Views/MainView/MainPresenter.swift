import UIKit

protocol MainPresenterProtocol {
    func didTapNewGame()
    func didTapLanguage()
    func didTapRules()
    func didTapPrivacy()
}

class MainPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    
    init(view: MainViewProtocol?) {
        self.view = view
    }
    
    func didTapNewGame() {
        view?.navigateToNewGame()
    }
    
    func didTapLanguage() {
        view?.navigateToLanguage()
    }
    
    func didTapRules() {
        view?.navigateToRules()
    }
    
    func didTapPrivacy() {
        view?.presentPrivacyPolicy()
    }
    
}
