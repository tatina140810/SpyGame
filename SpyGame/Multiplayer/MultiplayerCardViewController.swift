import UIKit
import MultipeerConnectivity

final class MultiplayerCardViewController: UIViewController {

    // MARK: - State

    private let role: PlayerRole
    private let config: GameConfig
    private let isHost: Bool
    private let session = MultiplayerSession.shared

    private var hasRevealed = false
    private var hasMarkedReady = false
    /// Host only: how many players (incl. self) tapped Ready.
    private var readyCount: Int = 0
    private var hasPushedTimer = false

    init(role: PlayerRole, config: GameConfig, isHost: Bool) {
        self.role = role
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

    private let playerNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private static func makeStackView(borderColor: UIColor, isHidden: Bool = false) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 2
        stackView.layer.borderColor = borderColor.cgColor
        stackView.isHidden = isHidden
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
        return stackView
    }

    private let frontStackView = MultiplayerCardViewController.makeStackView(borderColor: .white)
    private let wordStackView = MultiplayerCardViewController.makeStackView(borderColor: .white, isHidden: true)
    private let spyStackView = MultiplayerCardViewController.makeStackView(borderColor: .red, isHidden: true)

    private let frontImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .ШПИОН)
        return image
    }()

    private let frontLabel: UILabel = {
        let label = UILabel()
        label.text = "word_instruction".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let wordLabel: UILabel = {
        let label = UILabel()
        label.text = "word".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let spyLabel: UILabel = {
        let label = UILabel()
        label.text = "you_are_spy".localized
        label.textColor = .red
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ready".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.isHidden = true
        button.addTarget(self, action: #selector(handleReady), for: .touchUpInside)
        return button
    }()

    private let waitingSpinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .white
        view.hidesWhenStopped = true
        return view
    }()

    private let waitingLabel: UILabel = {
        let label = UILabel()
        label.text = "waiting_for_others".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        navigationItem.backButtonTitle = ""
        setupUI()
        playerNumberLabel.text = "player_of".localized(with: role.playerNumber, role.totalPlayers)
        wordLabel.text = role.word
        session.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Only release the idle-timer flag when we truly leave the card screen
        // (back to root). When we push the timer screen, it takes over the flag.
        if isMovingFromParent || isBeingDismissed {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        readyButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }

    // MARK: - Layout (mirrors StartGameViewController)

    private func setupUI() {
        [backgroundImage, cardView, playerNumberLabel, readyButton, waitingSpinner, waitingLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            playerNumberLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            playerNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 540),
            cardView.widthAnchor.constraint(equalToConstant: 340),

            readyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            readyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            readyButton.widthAnchor.constraint(equalToConstant: 240),
            readyButton.heightAnchor.constraint(equalToConstant: 50),

            waitingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waitingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            waitingLabel.topAnchor.constraint(equalTo: waitingSpinner.bottomAnchor, constant: 24),
            waitingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            waitingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        cardView.isUserInteractionEnabled = true
        cardView.addGestureRecognizer(tap)

        [frontStackView, wordStackView, spyStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
                $0.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
                $0.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
                $0.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
            ])
        }

        frontStackView.addArrangedSubview(frontImage)
        frontStackView.addArrangedSubview(frontLabel)
        wordStackView.addArrangedSubview(wordLabel)
        spyStackView.addArrangedSubview(spyLabel)
    }

    // MARK: - Card tap (reveal once)

    @objc private func handleCardTap() {
        guard !hasRevealed, !hasMarkedReady else { return }
        hasRevealed = true

        let toView: UIView = role.isSpy ? spyStackView : wordStackView
        let fromView: UIView = frontStackView
        fromView.isHidden = false
        toView.isHidden = false

        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.6,
                          options: [.transitionFlipFromRight, .showHideTransitionViews]) { _ in
            self.readyButton.isHidden = false
        }
    }

    // MARK: - Ready

    @objc private func handleReady() {
        guard hasRevealed, !hasMarkedReady else { return }
        hasMarkedReady = true

        cardView.isHidden = true
        playerNumberLabel.isHidden = true
        readyButton.isHidden = true
        waitingSpinner.startAnimating()
        waitingLabel.isHidden = false

        if isHost {
            readyCount += 1
            checkAllReady()
        } else {
            session.sendPlayerReady()
        }
    }

    private func checkAllReady() {
        guard isHost, !hasPushedTimer else { return }
        let expected = 1 + session.connectedPeers.count
        if readyCount >= expected {
            hasPushedTimer = true
            session.sendAllReadyStartTimer()
            pushTimer()
        }
    }

    private func pushTimer() {
        let timer = MultiplayerTimerViewController(config: config, isHost: isHost)
        navigationController?.pushViewController(timer, animated: true)
    }

    // MARK: - Helpers

    private func presentHostLeftAndQuit() {
        let alert = UIAlertController(title: "host_left".localized, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "done".localized, style: .default) { [weak self] _ in
            self?.session.disconnect()
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - MultiplayerSessionDelegate

extension MultiplayerCardViewController: MultiplayerSessionDelegate {
    func session(_ session: MultiplayerSession, didReceivePlayerReady peer: MCPeerID) {
        guard isHost else { return }
        readyCount += 1
        checkAllReady()
    }

    func sessionDidReceiveAllReady(_ session: MultiplayerSession) {
        guard !isHost, !hasPushedTimer else { return }
        hasPushedTimer = true
        pushTimer()
    }

    func session(_ session: MultiplayerSession, didChangePeers peers: [MCPeerID]) {
        if isHost {
            // If a guest dropped while host is still waiting for "Ready" — re-check the
            // threshold against the new (smaller) peer count, so the room doesn't deadlock.
            checkAllReady()
            return
        }
        // Guest fallback: if MCSession reports we have no peers left, the host is gone.
        // Normally we'd hear about it via .hostLeft, but if that packet got lost we still
        // need to bail out of the round.
        if peers.isEmpty {
            presentHostLeftAndQuit()
        }
    }

    func sessionHostDidLeave(_ session: MultiplayerSession) {
        guard !isHost else { return }
        presentHostLeftAndQuit()
    }

    func session(_ session: MultiplayerSession, didReceiveGameStart role: PlayerRole, config: GameConfig) {
        // Defensive: if host restarts the round while we're still on the card screen
        // (e.g. we lagged behind), replace ourselves with the new CardVC for the new role.
        guard !isHost else { return }
        guard let guestRoom = navigationController?.viewControllers.first(where: { $0 is GuestRoomViewController }) as? GuestRoomViewController else { return }
        let newCard = MultiplayerCardViewController(role: role, config: config, isHost: false)
        guestRoom.multiplayerResetStack(to: [newCard], animated: true)
    }
}
