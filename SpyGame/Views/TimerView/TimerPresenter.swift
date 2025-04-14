import  AVFoundation
import UIKit

protocol TimerPresenterProtocol: AnyObject {
    func viewDidLoad()
    func timerTick()
    func startNewGame()
}

final class TimerPresenter: TimerPresenterProtocol {
    private weak var view: TimerViewProtocol?
    private var timer: Timer?
    private var time: Int
    private var secondsLeft: Int
    
    init(view: TimerViewProtocol, time: Int) {
        self.view = view
        self.time = time
        self.secondsLeft = time
    }
    
    func viewDidLoad() {
        startCountdown()
    }
    
    private func startCountdown() {
        view?.showStartLabel()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    func timerTick() {
        secondsLeft -= 1
        
        if secondsLeft == 11 {
            view?.playBeepSound()
            view?.hideStartLabel()
        }
        
        if secondsLeft <= 0 {
            timer?.invalidate()
            view?.showEndGameLabel()
        }
    }
    
    func startNewGame() {
        timer?.invalidate()
    }
}
