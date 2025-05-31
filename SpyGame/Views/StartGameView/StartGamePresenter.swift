import Foundation

protocol StartGamePresenterProtocol {
    func handleCardTap()
    func viewDidLoad()
}

class StartGamePresenter: StartGamePresenterProtocol {
    
    private weak var view: StartGameViewProtocol?
    private var model: GameModel
    private var isShowingCard = false
    
    private var allWords: [String]
    private var usedWords: [String]
    
    init(view: StartGameViewProtocol, playersCount: Int, spyCount: Int, selectedWords: [String], time: Int) {
        
        self.view = view
        self.allWords = selectedWords
        self.usedWords = UserDefaults.standard.loadUsedWords()
        
        if usedWords.count >= allWords.count {
            usedWords.removeAll()
        }
        
        let commonWord = Self.pickUniqueWord(from: selectedWords, excluding: usedWords)
        usedWords.append(commonWord)
        UserDefaults.standard.saveUsedWords(usedWords)
        
        let spyIndexes = Set((0..<playersCount).shuffled().prefix(spyCount))
        
        self.model = GameModel(
            playersCount: playersCount,
            spyCount: spyCount,
            time: time,
            commonWord: commonWord,
            spyIndexes: spyIndexes,
            currentPlayerIndex: 0
        )
    }
    
    static func pickUniqueWord(from all: [String], excluding used: [String]) -> String {
        let remaining = all.filter { !used.contains($0) }
        return remaining.randomElement() ?? all.randomElement() ?? "word"
    }
    
    
    func viewDidLoad() {
        view?.showFrontCard(withInstruction: "word_instruction".localized)
    }
    
    func handleCardTap() {
        if isShowingCard {
            model.currentPlayerIndex += 1
            isShowingCard = false
            
            if model.currentPlayerIndex >= model.playersCount {
                view?.navigateToTimer(time: model.time)
            } else {
                view?.showFrontCard(withInstruction: "word_instruction".localized)
            }
        } else {
            let isSpy = model.spyIndexes.contains(model.currentPlayerIndex)
            
            if isSpy {
                
                view?.showSpyCard()
            } else {
                let word = model.commonWord
                var displayWord = word
                
                if word.hasPrefix("word_") {
                    let localized = word.localized
                    if localized == word {
                        
                    } else {
                        displayWord = localized
                    }
                }
                
                view?.showWordCard(withWord: displayWord)
            }
            
            isShowingCard = true
        }
    }
}
