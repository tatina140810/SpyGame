import Foundation
import StoreKit

protocol AddTopicPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapGenerate(topic: String?)
    func didTapSave(topic: String?)
}

class AddTopicPresenter: AddTopicPresenterProtocol {
    weak var view: AddTopicViewProtocol?
    weak var delegate: AddTopicDelegate?
    private var selectedLanguage: String
    private var generatedWords: [String] = []
    private var model: AddTopicModelProtocol
    private var themeUpdater: ThemeUpdaterProtocol
    
    init(view: AddTopicViewProtocol,
         delegate: AddTopicDelegate?,
         language: String,
         model: AddTopicModelProtocol = AddTopicModel(),
         themeUpdater: ThemeUpdaterProtocol = DefaultThemeUpdater()) {
        self.view = view
        self.delegate = delegate
        self.selectedLanguage = language
        self.model = model
        self.themeUpdater = themeUpdater
    }
    func viewDidLoad() {
        updateRequestInfo()
    }
    
    func didTapGenerate(topic: String?) {
        guard let topic = topic, !topic.isEmpty else {
            
            view?.showAlert(title: "Ошибка", message: "Введите тему")
            return
        }
        
        
        guard model.canMakeRequest() else {
            
            view?.showAlert(title: "limit_reached_title".localized,
                            message: "limit_reached_message".localized)
            return
        }
        
        model.incrementRequestCount()
        updateRequestInfo()
        
        model.generateWords(topic: topic, language: selectedLanguage) { [weak self] words in
            guard let self = self else { return }
            self.generatedWords = words
            
            DispatchQueue.main.async {
                
                self.view?.showGeneratedWords(words)
                
                let message = "words_generated_for_topic".localized(with: words.count, topic)
                
                self.view?.showAlert(title: "success_title".localized, message: message)
                
                
                
                self.delegate?.updateCustomButtonTitle(to: topic)
                
            }
            
        }
    }
    
    func didTapSave(topic: String?) {
        guard let topic = topic?.trimmingCharacters(in: .whitespacesAndNewlines), !topic.isEmpty else {
            view?.showAlert(title: "error", message: "enter_topic".localized)
            return
        }
        
        if !isValidTopicInput(topic) {
            view?.showAlert(title: "error", message: "invalid_topic_format".localized)
            return
        }
        
        themeUpdater.saveCustomTheme(words: generatedWords)
        themeUpdater.selectCustomTheme(named: "theme_custom", title: topic)
        delegate?.didCreateTopic(name: topic, words: generatedWords, language: selectedLanguage)
        view?.close()
    }
    
    
    private func updateRequestInfo() {
        let remaining = model.remainingRequests()
        view?.updateRequestInfo(remaining: remaining)
    }
    func isValidTopicInput(_ word: String) -> Bool {
        
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return false }
        
        let allowedCharacterSet = CharacterSet.letters
        let wordCharacterSet = CharacterSet(charactersIn: trimmed)
        return allowedCharacterSet.isSuperset(of: wordCharacterSet)
    }
    static func checkEntitlements() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == "wordgen_premium" {
                return true
            }
        }
        return false
    }
}



