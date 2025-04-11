import Foundation

protocol StartGamePresenterProtocol {
    func handleCardTap()
    func viewDidLoad()
}

class StartGamePresenter {
    private weak var view: StartGameViewProtocol?
    private var model: GameModel
    private var isShowingCard = false 
    
    init(view: StartGameViewProtocol, playersCount: Int, spyCount: Int, selectedWords: [String], time: Int) {
        self.view = view
        let commonWord = selectedWords.randomElement() ?? "Слово"
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
    
    func handleCardTap() {
        if isShowingCard {
            model.currentPlayerIndex += 1
            isShowingCard = false
            
            if model.currentPlayerIndex >= model.playersCount {
                view?.navigateToTimer(time: model.time)
            } else {
                view?.showFrontCard(withInstruction: "Нажмите на карточку и запомните слово")
            }
        } else {
            let isCurrentPlayerSpy = model.spyIndexes.contains(model.currentPlayerIndex)
            if isCurrentPlayerSpy {
                view?.showSpyCard()
            } else {
                view?.showWordCard(withWord: model.commonWord)
            }
            isShowingCard = true
        }
    }
    
}
