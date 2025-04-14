import UIKit
import SnapKit
import AVFoundation

protocol TimerViewProtocol: AnyObject {
    func showStartLabel()
    func hideStartLabel()
    func showEndGameLabel()
    func playBeepSound()
}

class TimerViewController: UIViewController, TimerViewProtocol {
    
    var presenter: TimerPresenterProtocol?
    
    private let time: Int
    private var audioPlayer: AVAudioPlayer?
    private let timerView = CircularTimerView()
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .screenshot20250409At101528Pm)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.8
        return imageView
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGreen
        view.layer.cornerRadius = 20
        return view
    }()
    private let startGameLabel: UILabel = {
        let label = UILabel()
        label.text = "game_started!".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.isHidden = false
        return label
    }()
    
    private let endGameLabel: UILabel = {
        let label = UILabel()
        label.text = "game_over".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        label.isHidden = true
        return label
    }()
    
    private lazy var newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("start_new_game".localized, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleNewGameButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(time: Int) {
        self.time = time
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        setupUI()
        presenter?.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        newGameButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }
    
    private func setupUI() {
        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        view.addSubview(cardView)
        cardView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(600)
            $0.width.equalTo(340)
        }
        
        view.addSubview(newGameButton)
        newGameButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-40)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(240)
        }
        cardView.addSubview(startGameLabel)
        startGameLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.top).offset(30)
            make.centerX.equalToSuperview()
        }
        
        cardView.addSubview(timerView)
        timerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(200)
        }
        
        cardView.addSubview(endGameLabel)
        endGameLabel.snp.makeConstraints {
            $0.bottom.equalTo(cardView.snp.bottom).offset(-50)
            $0.centerX.equalToSuperview()
        }
        
        timerView.start(duration: Double(time))
        timerView.onTimerFinished = { [weak presenter] in
            presenter?.timerTick()
        }
    }
    
    func showStartLabel() {
        startGameLabel.isHidden = false
    }
    
    func hideStartLabel() {
        startGameLabel.isHidden = true
    }
    
    func showEndGameLabel() {
        endGameLabel.isHidden = false
        endGameLabel.alpha = 0.0
        endGameLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: [],
                       animations: {
            self.endGameLabel.alpha = 1.0
            self.endGameLabel.transform = .identity
        }, completion: nil)
    }
    
    func playBeepSound() {
        guard let url = Bundle.main.url(forResource: "zvuk", withExtension: "wav") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Ошибка воспроизведения: \(error.localizedDescription)")
        }
    }
    
    @objc private func handleNewGameButtonTapped() {
        guard UserDefaults.standard.loadGameSettings() != nil else {
            return
        }
        
        let newGameVC = StartGameViewController()
        
        if let setupVC = navigationController?.viewControllers.first(where: { $0 is PlayersSetupViewController }) {
            navigationController?.setViewControllers([setupVC, newGameVC], animated: true)
        } else {
            navigationController?.setViewControllers([newGameVC], animated: true)
        }
    }
    
    
}
