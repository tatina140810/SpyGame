import UIKit
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
    let timerView = CircularTimerView()
    
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
    private lazy var pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("pause".localized, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        return button
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
        pauseButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }
    
    private func setupUI() {
        
        [backgroundImage, cardView, newGameButton, startGameLabel, timerView, endGameLabel, pauseButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        view.addSubview(backgroundImage)
        view.addSubview(cardView)
        view.addSubview(newGameButton)
        
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 600),
            cardView.widthAnchor.constraint(equalToConstant: 340),
            
            newGameButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.heightAnchor.constraint(equalToConstant: 50),
            newGameButton.widthAnchor.constraint(equalToConstant: 240)
        ])
        
        
        cardView.addSubview(startGameLabel)
        cardView.addSubview(timerView)
        cardView.addSubview(endGameLabel)
        cardView.addSubview(pauseButton)
        
        NSLayoutConstraint.activate([
            startGameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            startGameLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            timerView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            timerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            timerView.widthAnchor.constraint(equalToConstant: 200),
            timerView.heightAnchor.constraint(equalToConstant: 200),
            
            endGameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -50),
            endGameLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            pauseButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            pauseButton.heightAnchor.constraint(equalToConstant: 50),
            pauseButton.widthAnchor.constraint(equalToConstant: 240),
            pauseButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -100)
        ])
        
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
        
        audioPlayer?.stop()
        audioPlayer = nil
        
        guard let url = Bundle.main.url(forResource: "zvuk", withExtension: "wav") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

        } catch {
         
        }
    }
    
    
    deinit {
        audioPlayer?.stop()
        audioPlayer = nil
        
    }
    func pauseSound() {
        audioPlayer?.pause()
    }
    
    func resumeSound() {
        audioPlayer?.play()
    }
    
    @objc private func handleNewGameButtonTapped() {
        guard let settings = UserDefaults.standard.loadGameSettings() else {
            return
        }

        let loadedWords = UserDefaults.standard.stringArray(forKey: "last_selected_words") ?? []
        let newGameVC = StartGameViewController(words: loadedWords)

        guard let nav = navigationController else {
            return
        }

        if let setupVC = nav.viewControllers.first(where: { $0 is PlayersSetupViewController }) {
            nav.popToViewController(setupVC, animated: false)
            nav.pushViewController(newGameVC, animated: true)
        } else {
            nav.setViewControllers([newGameVC], animated: true)
        }
    }


    @objc private func pauseButtonTapped() {
        if timerView.isPaused {
            timerView.resume()
            resumeSound()
            pauseButton.setTitle("pause".localized, for: .normal)
        } else {
            timerView.paused()
            pauseSound()
            pauseButton.setTitle("continue".localized, for: .normal)
        }
    }
    
    
    
}
