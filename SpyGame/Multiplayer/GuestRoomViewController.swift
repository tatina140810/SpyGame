import UIKit
import MultipeerConnectivity

final class GuestRoomViewController: UIViewController {

    // MARK: - State

    private let session = MultiplayerSession.shared
    private var discoveredPeers: [(peer: MCPeerID, code: String)] = []
    private var enteredCode: String = ""

    private enum Stage { case entering, connecting, connected }
    private var stage: Stage = .entering {
        didSet { applyStage() }
    }

    // MARK: - UI

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

    private let promptLabel: UILabel = {
        let label = UILabel()
        label.text = "enter_room_code".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let codeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "----"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 32, weight: .bold)
        textField.textColor = .darkGreen
        return textField
    }()

    private lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("join".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(handleJoin), for: .touchUpInside)
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        view.color = .white
        return view
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        setupUI()
        applyStage()
        session.delegate = self
        hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        joinButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            session.delegate = nil
            session.disconnect()
        }
    }

    // MARK: - Layout

    private func setupUI() {
        [backgroundImage, cardView].forEach {
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
            cardView.heightAnchor.constraint(equalToConstant: 500)
        ])

        [promptLabel, codeTextField, joinButton, statusLabel, spinner].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 60),
            promptLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 30),
            promptLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -30),

            codeTextField.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 30),
            codeTextField.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            codeTextField.widthAnchor.constraint(equalToConstant: 180),
            codeTextField.heightAnchor.constraint(equalToConstant: 60),

            joinButton.topAnchor.constraint(equalTo: codeTextField.bottomAnchor, constant: 30),
            joinButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            joinButton.widthAnchor.constraint(equalToConstant: 200),
            joinButton.heightAnchor.constraint(equalToConstant: 50),

            spinner.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            statusLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
    }

    private func applyStage() {
        switch stage {
        case .entering:
            promptLabel.isHidden = false
            codeTextField.isHidden = false
            joinButton.isHidden = false
            spinner.stopAnimating()
            statusLabel.isHidden = true
        case .connecting:
            promptLabel.isHidden = true
            codeTextField.isHidden = true
            joinButton.isHidden = true
            spinner.startAnimating()
            statusLabel.text = "connecting".localized
            statusLabel.isHidden = false
        case .connected:
            promptLabel.isHidden = true
            codeTextField.isHidden = true
            joinButton.isHidden = true
            spinner.startAnimating()
            statusLabel.text = "waiting_for_host".localized
            statusLabel.isHidden = false
        }
    }

    // MARK: - Actions

    @objc private func handleJoin() {
        let trimmed = (codeTextField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard trimmed.count == 4, trimmed.allSatisfy(\.isNumber) else {
            shakeTextField()
            return
        }
        enteredCode = trimmed
        stage = .connecting
        session.startBrowsing()
        // If host was already discovered before user typed the code — connect right away.
        tryConnectIfMatch()
    }

    private func shakeTextField() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-12.0, 12.0, -10.0, 10.0, -6.0, 6.0, -2.0, 2.0, 0.0]
        codeTextField.layer.add(animation, forKey: "shake")
    }

    private func tryConnectIfMatch() {
        guard !enteredCode.isEmpty else { return }
        if let match = discoveredPeers.first(where: { $0.code == enteredCode }) {
            session.connect(to: match.peer, roomCode: enteredCode)
        }
    }

    private func showAlertAndPop(messageKey: String) {
        let alert = UIAlertController(title: nil, message: messageKey.localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "done".localized, style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - MultiplayerSessionDelegate

extension GuestRoomViewController: MultiplayerSessionDelegate {
    func session(_ session: MultiplayerSession, didDiscoverPeer peer: MCPeerID, roomCode: String?) {
        guard let code = roomCode else { return }
        if !discoveredPeers.contains(where: { $0.peer == peer }) {
            discoveredPeers.append((peer, code))
        }
        if stage == .connecting {
            tryConnectIfMatch()
        }
    }

    func session(_ session: MultiplayerSession, didLosePeer peer: MCPeerID) {
        discoveredPeers.removeAll { $0.peer == peer }
    }

    func session(_ session: MultiplayerSession, didChangePeers peers: [MCPeerID]) {
        if !peers.isEmpty && stage == .connecting {
            stage = .connected
            session.stopBrowsing()
        } else if peers.isEmpty && stage == .connected {
            showAlertAndPop(messageKey: "host_left")
        }
    }

    func session(_ session: MultiplayerSession, didReceiveGameStart role: PlayerRole, config: GameConfig) {
        let cardVC = MultiplayerCardViewController(role: role, config: config, isHost: false)
        navigationController?.pushViewController(cardVC, animated: true)
    }

    func sessionHostDidLeave(_ session: MultiplayerSession) {
        showAlertAndPop(messageKey: "host_left")
    }

    func session(_ session: MultiplayerSession, didFailWith error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "done".localized, style: .default))
        present(alert, animated: true)
    }
}
