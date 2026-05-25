import UIKit
import AVFoundation
import MultipeerConnectivity

final class MultiplayerTimerViewController: UIViewController {

    // MARK: - State

    private let config: GameConfig
    private let isHost: Bool
    private let session = MultiplayerSession.shared
    private var audioPlayer: AVAudioPlayer?
    private let timerView = CircularTimerView()
    private var alreadyShownDisconnect = false

    init(config: GameConfig, isHost: Bool) {
        self.config = config
        self.isHost = isHost
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI

    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .background)
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
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()

    private lazy var newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("start_new_game".localized, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleNewGame), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        navigationItem.backButtonTitle = ""
        if isHost {
            let leaveItem = UIBarButtonItem(title: "leave_room".localized,
                                            style: .plain,
                                            target: self,
                                            action: #selector(handleLeaveRoom))
            leaveItem.tintColor = .systemRed
            navigationItem.rightBarButtonItem = leaveItem
        }
        setupUI()
        UIApplication.shared.isIdleTimerDisabled = true
        session.delegate = self

        // Only host sees the "New Game" button — guests should not control the room.
        newGameButton.isHidden = !isHost

        timerView.start(duration: Double(config.timerDuration))
        timerView.onSecondTick = { [weak self] secondsLeft in
            if secondsLeft == 11 {
                self?.playBeepSound()
                self?.startGameLabel.isHidden = true
            }
        }
        timerView.onTimerFinished = { [weak self] in
            self?.showEndGameLabel()
        }
        AdManager.shared.attachBanner(to: view, viewController: self)
        UserDefaults.standard.incrementPlayedGames()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        newGameButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        pauseButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Layout (mirrors TimerViewController)

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

            newGameButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -40 - (PremiumIAP.isUnlocked() ? 0 : AdManager.bannerHeight + 20)
            ),
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

            endGameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            endGameLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            pauseButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            pauseButton.heightAnchor.constraint(equalToConstant: 50),
            pauseButton.widthAnchor.constraint(equalToConstant: 240),
            pauseButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -100)
        ])
    }

    // MARK: - Timer effects

    private func playBeepSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        guard let url = Bundle.main.url(forResource: "zvuk", withExtension: "wav") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            #if DEBUG
            print("[Timer] beep failed: \(error)")
            #endif
        }
    }

    private func showEndGameLabel() {
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

    // MARK: - Actions

    @objc private func handlePause() {
        if timerView.isPaused {
            timerView.resume()
            audioPlayer?.play()
            pauseButton.setTitle("pause".localized, for: .normal)
        } else {
            timerView.paused()
            audioPlayer?.pause()
            pauseButton.setTitle("continue".localized, for: .normal)
        }
    }

    @objc private func handleLeaveRoom() {
        // Disconnect explicitly — `viewWillDisappear` on mid-stack VCs isn't reliable
        // during a `popToRoot`. `disconnect()` is idempotent now.
        session.disconnect()
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func handleNewGame() {
        guard isHost else { return }
        // Stay connected — find the lobby below us in the stack and ask it to start the
        // next round. Guests learn about it via the regular `gameStart` message.
        if let hostRoom = navigationController?.viewControllers.first(where: { $0 is HostRoomViewController }) as? HostRoomViewController {
            hostRoom.restartGame()
        } else {
            // Lobby is gone for some reason — fall back to a clean exit.
            session.disconnect()
            navigationController?.popToRootViewController(animated: true)
        }
    }
}

// MARK: - MultiplayerSessionDelegate

extension MultiplayerTimerViewController: MultiplayerSessionDelegate {
    func session(_ session: MultiplayerSession, didChangePeers peers: [MCPeerID]) {
        // Guest fallback: lost all peers => host is gone (even if .hostLeft never arrived).
        if !isHost && peers.isEmpty {
            presentHostLeftAndQuit()
            return
        }
        // Otherwise — someone else in the room dropped; show one-time notice and continue.
        let expected = config.totalPlayers - 1
        if peers.count < expected && !alreadyShownDisconnect {
            alreadyShownDisconnect = true
            let alert = UIAlertController(title: "player_disconnected".localized,
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "done".localized, style: .default))
            present(alert, animated: true)
        }
    }

    private func presentHostLeftAndQuit() {
        let alert = UIAlertController(title: "host_left".localized, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "done".localized, style: .default) { [weak self] _ in
            self?.session.disconnect()
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }

    func sessionHostDidLeave(_ session: MultiplayerSession) {
        guard !isHost else { return }
        presentHostLeftAndQuit()
    }

    func session(_ session: MultiplayerSession, didReceiveGameStart role: PlayerRole, config: GameConfig) {
        // Host started the next round while we were on the timer. Replace the per-round
        // screens with a fresh CardVC, keeping our lobby (GuestRoomViewController) below.
        guard !isHost else { return }
        guard let guestRoom = navigationController?.viewControllers.first(where: { $0 is GuestRoomViewController }) as? GuestRoomViewController else { return }
        let newCard = MultiplayerCardViewController(role: role, config: config, isHost: false)
        guestRoom.multiplayerResetStack(to: [newCard], animated: true)
    }
}
