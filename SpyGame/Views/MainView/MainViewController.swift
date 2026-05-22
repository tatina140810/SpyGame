import UIKit

protocol MainViewProtocol: AnyObject {
    func navigateToNewGame()
    func navigateToPlayTogether()
    func navigateToLanguage()
    func navigateToRules()
    func presentPrivacyPolicy()
}

class MainViewController: UIViewController, MainViewProtocol {
    
    var presenter: MainPresenterProtocol!
    
    private var backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .background)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.8
        return imageView
    }()
    
    private lazy var newGameButton = makeButton(titleKey: "new_game", action: #selector(handleNewGame))
    private lazy var playTogetherButton = makeButton(titleKey: "play_together", action: #selector(handlePlayTogether))
    private lazy var languageButton = makeButton(titleKey: "language_selection", action: #selector(handleLanguage))
    private lazy var rulesButton = makeButton(titleKey: "rules", action: #selector(handleRules))
    
    
    private lazy var privacyPolicyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("privacy_policy".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handlePrivacy), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainPresenter(view: self)
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Only show interstitial if at least one game has finished — avoids
        // hitting the user with an ad on cold start. AdManager itself throttles
        // to at most once per 3 minutes and no-ops for premium users.
        if UserDefaults.standard.playedGamesCount() > 0 {
            AdManager.shared.showInterstitialIfReady(from: self)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        [newGameButton, playTogetherButton, languageButton, rulesButton].forEach {
            $0.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        navigationItem.backButtonTitle = ""
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let buttons = [newGameButton, playTogetherButton, languageButton, rulesButton, privacyPolicyButton]
        
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                button.heightAnchor.constraint(equalToConstant: 50),
                button.widthAnchor.constraint(equalToConstant: 240)
            ])
        }
        
        NSLayoutConstraint.activate([
            newGameButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),

            playTogetherButton.topAnchor.constraint(equalTo: newGameButton.bottomAnchor, constant: 24),
            languageButton.topAnchor.constraint(equalTo: playTogetherButton.bottomAnchor, constant: 24),
            rulesButton.topAnchor.constraint(equalTo: languageButton.bottomAnchor, constant: 24),
            privacyPolicyButton.topAnchor.constraint(equalTo: rulesButton.bottomAnchor, constant: 24)
        ])
    }
    
    private func makeButton(titleKey: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle(titleKey.localized, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func handleNewGame() { presenter.didTapNewGame() }
    @objc private func handlePlayTogether() { presenter.didTapPlayTogether() }
    @objc private func handleLanguage() { presenter.didTapLanguage() }
    @objc private func handleRules() { presenter.didTapRules() }
    @objc private func handlePrivacy() { presenter.didTapPrivacy() }


    func navigateToNewGame() {
        let presenter = PlayersSetupPresenter()
        let vc = PlayersSetupViewController(presenter: presenter)
        presenter.view = vc
        navigationController?.pushViewController(vc, animated: true)
    }

    func navigateToPlayTogether() {
        let vc = RoomSetupViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToLanguage() {
        let vc = LanguageViewController()
        vc.presenter = LanguagePresenter(view: vc)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToRules() {
        let vc = RulesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentPrivacyPolicy() {
        let vc = PrivacyPolicyViewController()
        navigationController?.present(vc, animated: true)
    }
}
