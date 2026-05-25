import UIKit
import MultipeerConnectivity

final class HostRoomViewController: UIViewController {

    // MARK: - State

    private let session = MultiplayerSession.shared
    private var roomCode: String = ""
    private var spyCount: Int = 1
    private var timerDuration: Int = 60

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

    private let roomCodeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "room_code".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let roomCodeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let playersCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let playersListStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    private let spyLabel: UILabel = {
        let label = UILabel()
        label.text = "spies_count:".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let spyCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.text = "1"
        return label
    }()

    private lazy var minusSpyButton = makeStepperButton(symbol: "minus", action: #selector(decreaseSpies))
    private lazy var plusSpyButton = makeStepperButton(symbol: "plus", action: #selector(increaseSpies))

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "time:".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private lazy var oneMinButton = makeTimeButton(titleKey: "minute_1", action: #selector(selectOneMinute))
    private lazy var twoMinButton = makeTimeButton(titleKey: "minute_2", action: #selector(selectTwoMinutes))
    private lazy var threeMinButton = makeTimeButton(titleKey: "minute_3", action: #selector(selectThreeMinutes))

    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("start_game".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        let leaveItem = UIBarButtonItem(title: "leave_room".localized,
                                        style: .plain,
                                        target: self,
                                        action: #selector(handleLeaveRoom))
        leaveItem.tintColor = .systemRed
        navigationItem.rightBarButtonItem = leaveItem
        loadSettings()
        roomCode = MultiplayerSession.generateRoomCode()
        setupUI()
        refreshAllUI()
        session.delegate = self
        session.maxAllowedPeers = PremiumIAP.isUnlocked() ? 14 : 3
        session.startHosting(roomCode: roomCode)
        installAdBanner()
    }

    @objc private func handleLeaveRoom() {
        // Disconnect explicitly here — UIKit doesn't always deliver `viewWillDisappear`
        // to mid-stack VCs during a `popToRoot`, so the lifecycle hook below isn't
        // reliable. `disconnect()` is now idempotent, so calling it twice is fine.
        session.disconnect()
        navigationController?.popToRootViewController(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        startButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            session.delegate = nil
            session.disconnect()
        }
    }

    // MARK: - Setup

    private func loadSettings() {
        if let saved = UserDefaults.standard.loadGameSettings() {
            spyCount = max(1, min(3, saved.spyCount))
            timerDuration = [60, 120, 180].contains(saved.selectedTime) ? saved.selectedTime : 60
        }
    }

    private func setupUI() {
        [backgroundImage, cardView, startButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 340),
            cardView.heightAnchor.constraint(equalToConstant: 600),

            startButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -40 - (PremiumIAP.isUnlocked() ? 0 : AdManager.bannerHeight + 20)
            ),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 240),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        let spyStack = UIStackView(arrangedSubviews: [minusSpyButton, spyCountLabel, plusSpyButton])
        spyStack.axis = .horizontal
        spyStack.spacing = 16
        spyStack.alignment = .center
        spyStack.distribution = .equalCentering

        let timeStack = UIStackView(arrangedSubviews: [oneMinButton, twoMinButton, threeMinButton])
        timeStack.axis = .horizontal
        timeStack.spacing = 8
        timeStack.distribution = .fillEqually

        let mainStack = UIStackView(arrangedSubviews: [
            roomCodeTitleLabel,
            roomCodeLabel,
            playersCountLabel,
            playersListStackView,
            spyLabel,
            spyStack,
            timeLabel,
            timeStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 14
        mainStack.alignment = .fill
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            timeStack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func makeStepperButton(symbol: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbol), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func makeTimeButton(titleKey: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(titleKey.localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - State refresh

    private func refreshAllUI() {
        roomCodeLabel.text = roomCode
        spyCountLabel.text = "\(spyCount)"
        updatePlayersList()
        updateTimeButtonHighlight()
    }

    private func updatePlayersList() {
        let total = 1 + session.connectedPeers.count
        playersCountLabel.text = "players_in_room".localized + ": \(total)"

        playersListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let hostRow = UILabel()
        hostRow.text = "• \(session.myPeerID.displayName) (host)"
        hostRow.textColor = .white
        hostRow.font = .systemFont(ofSize: 13)
        playersListStackView.addArrangedSubview(hostRow)

        for peer in session.connectedPeers {
            let row = UILabel()
            row.text = "• \(peer.displayName)"
            row.textColor = .white
            row.font = .systemFont(ofSize: 13)
            playersListStackView.addArrangedSubview(row)
        }

        startButton.isEnabled = total >= 3
        startButton.alpha = startButton.isEnabled ? 1.0 : 0.5
    }

    private func updateTimeButtonHighlight() {
        let map: [(UIButton, Int)] = [(oneMinButton, 60), (twoMinButton, 120), (threeMinButton, 180)]
        for (button, seconds) in map {
            let isSelected = (seconds == timerDuration)
            button.backgroundColor = isSelected ? .white : .clear
            button.setTitleColor(isSelected ? .darkGreen : .white, for: .normal)
            button.layer.borderColor = (isSelected ? UIColor.darkGreen : UIColor.white).cgColor
        }
    }

    // MARK: - Actions

    @objc private func increaseSpies() {
        guard spyCount < 3 else { return }
        spyCount += 1
        spyCountLabel.text = "\(spyCount)"
    }

    @objc private func decreaseSpies() {
        guard spyCount > 1 else { return }
        spyCount -= 1
        spyCountLabel.text = "\(spyCount)"
    }

    @objc private func selectOneMinute() { timerDuration = 60; updateTimeButtonHighlight() }
    @objc private func selectTwoMinutes() { timerDuration = 120; updateTimeButtonHighlight() }
    @objc private func selectThreeMinutes() { timerDuration = 180; updateTimeButtonHighlight() }

    @objc private func handleStart() {
        let total = 1 + session.connectedPeers.count
        if !PremiumIAP.isUnlocked() && total > 4 {
            presentPaywall()
            return
        }
        guard total >= 3 else { return }
        startRound(total: total, mode: .initialPush)
    }

    /// Called by the timer screen when host taps "New Game".
    /// Reuses every player who is still connected and starts the next round.
    func restartGame() {
        let total = 1 + session.connectedPeers.count
        if !PremiumIAP.isUnlocked() && total > 4 {
            presentPaywall()
            return
        }
        guard total >= 3 else {
            showAlert(message: "player_disconnected".localized)
            return
        }
        startRound(total: total, mode: .replaceStack)
    }

    private enum RoundMode {
        case initialPush     // first round — push CardVC on top of self
        case replaceStack    // next round — drop CardVC + TimerVC, leave self + new CardVC
    }

    private func presentPaywall() {
        let paywall = PaywallViewController()
        paywall.onPurchaseSuccess = { [weak self] in
            self?.session.maxAllowedPeers = 14
        }
        let nav = UINavigationController(rootViewController: paywall)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    private func startRound(total: Int, mode: RoundMode) {
        let themeKeys: [String]
        if let saved = UserDefaults.standard.loadGameSettings(), !saved.selectedThemeNames.isEmpty {
            themeKeys = saved.selectedThemeNames
        } else {
            themeKeys = allThemes.map { $0.nameKey }
        }
        let helper = PlayersSetupPresenter()
        let words = helper.getAllWords(from: themeKeys)
        guard let chosenWord = words.randomElement() else {
            showAlert(message: "game_settings_missing".localized)
            return
        }
        let displayWord = chosenWord.hasPrefix("word_") ? chosenWord.localized : chosenWord

        let allPeers: [MCPeerID] = [session.myPeerID] + session.connectedPeers
        let spyIndices = Set((0..<total).shuffled().prefix(spyCount))

        var rolesToSend: [MCPeerID: PlayerRole] = [:]
        var myRole: PlayerRole?
        for (index, peer) in allPeers.enumerated() {
            let isSpy = spyIndices.contains(index)
            let role = PlayerRole(
                isSpy: isSpy,
                word: isSpy ? nil : displayWord,
                playerNumber: index + 1,
                totalPlayers: total,
                spyCount: spyCount
            )
            if peer == session.myPeerID {
                myRole = role
            } else {
                rolesToSend[peer] = role
            }
        }

        let config = GameConfig(timerDuration: timerDuration, totalPlayers: total)
        session.sendGameStartToAll(roles: rolesToSend, config: config)

        guard let mine = myRole else { return }
        let cardVC = MultiplayerCardViewController(role: mine, config: config, isHost: true)
        switch mode {
        case .initialPush:
            navigationController?.pushViewController(cardVC, animated: true)
        case .replaceStack:
            multiplayerResetStack(to: [cardVC], animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "done".localized, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MultiplayerSessionDelegate

extension HostRoomViewController: MultiplayerSessionDelegate {
    func session(_ session: MultiplayerSession, didChangePeers peers: [MCPeerID]) {
        updatePlayersList()
    }

    func session(_ session: MultiplayerSession, didFailWith error: Error) {
        showAlert(message: error.localizedDescription)
    }
}
