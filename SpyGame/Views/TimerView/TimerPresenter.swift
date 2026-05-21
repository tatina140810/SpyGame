import UIKit

protocol TimerPresenterProtocol: AnyObject {
    func viewDidLoad()
    func timerDidFinish()
}

final class TimerPresenter: TimerPresenterProtocol {
    private weak var view: TimerViewProtocol?

    init(view: TimerViewProtocol, time: Int) {
        self.view = view
    }

    func viewDidLoad() {
        view?.showStartLabel()
        guard let vc = view as? TimerViewController else { return }
        vc.timerView.onSecondTick = { [weak self] secondsLeft in
            self?.handleTick(secondsLeft: secondsLeft)
        }
    }

    private func handleTick(secondsLeft: Int) {
        if secondsLeft == 11 {
            view?.playBeepSound()
            view?.hideStartLabel()
        }
    }

    func timerDidFinish() {
        view?.showEndGameLabel()
    }
}
