import UIKit

protocol ThemesViewControllerProtocol: AnyObject {
    func reloadInterface()
    func updateCustomButtonTitle(to title: String)
}

class ThemesViewController: UIViewController, ThemesViewControllerProtocol {

    var presenter: ThemesPresenterProtocol?
    var onThemesSelected: (([String]) -> Void)?
    var shouldSelectAllThemes: Bool = false

    var onCustomThemeSet: ((String) -> Void)?

    private let allThemeKeys = [
        "theme_food", "theme_animals", "theme_jobs",
        "theme_transport", "theme_movies", "theme_travel",
        "theme_sports", "theme_celebrities", "theme_countries",
        "theme_tv_shows", "theme_music", "theme_custom"
    ]

    /// Rebuilt every time `highlightSelectedThemes()` runs. 1:1 with `themeButtons`.
    private var visibleThemeKeys: [String] = []
    private var themeButtons: [UIButton] = []

    private var customThemeTitle: String = {
        return UserDefaults.standard.string(forKey: "custom_theme_title") ?? "theme_custom".localized
    }()

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

    private let themesScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let themesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        return stack
    }()

    private lazy var safeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("apply".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(safeButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var addYourTopicButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("add_Your_Topic".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(addYourTopicButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""

        if presenter == nil {
            presenter = ThemesPresenter(view: self)
        }

        if shouldSelectAllThemes {
            presenter?.selectAllThemes(keys: allThemeKeys)
        }

        setupUI()
        presenter?.viewDidLoad()
        highlightSelectedThemes()
        installAdBanner()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        highlightSelectedThemes()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        addYourTopicButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        safeButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }

    // MARK: - Layout

    private func setupUI() {
        [backgroundImage, cardView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        [themesScrollView, themesStackView, safeButton, addYourTopicButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 600),
            cardView.widthAnchor.constraint(equalToConstant: 340)
        ])

        cardView.addSubview(safeButton)
        cardView.addSubview(addYourTopicButton)
        cardView.addSubview(themesScrollView)
        themesScrollView.addSubview(themesStackView)

        NSLayoutConstraint.activate([
            safeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -25),
            safeButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            safeButton.widthAnchor.constraint(equalToConstant: 200),
            safeButton.heightAnchor.constraint(equalToConstant: 44),

            addYourTopicButton.bottomAnchor.constraint(equalTo: safeButton.topAnchor, constant: -15),
            addYourTopicButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            addYourTopicButton.widthAnchor.constraint(equalToConstant: 200),
            addYourTopicButton.heightAnchor.constraint(equalToConstant: 44),

            themesScrollView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            themesScrollView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            themesScrollView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            themesScrollView.bottomAnchor.constraint(equalTo: addYourTopicButton.topAnchor, constant: -15),

            themesStackView.topAnchor.constraint(equalTo: themesScrollView.contentLayoutGuide.topAnchor),
            themesStackView.bottomAnchor.constraint(equalTo: themesScrollView.contentLayoutGuide.bottomAnchor),
            themesStackView.leadingAnchor.constraint(equalTo: themesScrollView.contentLayoutGuide.leadingAnchor),
            themesStackView.trailingAnchor.constraint(equalTo: themesScrollView.contentLayoutGuide.trailingAnchor),
            themesStackView.widthAnchor.constraint(equalTo: themesScrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    // MARK: - Theme buttons (dynamic)

    private func rebuildThemeButtons() {
        themesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        themeButtons.removeAll()
        visibleThemeKeys.removeAll()

        // theme_custom only shown if a custom theme is saved.
        for key in allThemeKeys {
            if key == "theme_custom" && customTheme == nil { continue }
            let button = makeThemeButton(key: key)
            themesStackView.addArrangedSubview(button)
            themeButtons.append(button)
            visibleThemeKeys.append(key)
        }
    }

    private func makeThemeButton(key: String) -> UIButton {
        let button = UIButton(type: .system)
        let title = (key == "theme_custom") ? customThemeTitle : key.localized
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(themeButtonTapped(_:)), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 240),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        return button
    }

    private func highlightSelectedThemes() {
        rebuildThemeButtons()
        for (index, key) in visibleThemeKeys.enumerated() {
            let isSelected = presenter?.selectedThemes.contains(key) ?? false
            updateButtonAppearance(themeButtons[index], isSelected: isSelected)
        }
    }

    private func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
            button.layer.borderColor = UIColor.black.cgColor
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor.white.cgColor
        }
    }

    // MARK: - Actions

    @objc private func themeButtonTapped(_ sender: UIButton) {
        guard let index = themeButtons.firstIndex(of: sender), index < visibleThemeKeys.count else { return }
        let key = visibleThemeKeys[index]
        toggle(key, button: sender)
    }

    private func toggle(_ key: String, button: UIButton) {
        let wasSelected = presenter?.selectedThemes.contains(key) ?? false
        if wasSelected {
            presenter?.deselectTheme(named: key)
        } else {
            presenter?.selectTheme(named: key)
        }
        let isNowSelected = presenter?.selectedThemes.contains(key) ?? false
        updateButtonAppearance(button, isSelected: isNowSelected)
    }

    @objc private func safeButtonTapped() {
        if let selected = presenter?.selectedThemes {
            onThemesSelected?(selected)
        }
        navigationController?.popViewController(animated: true)
    }

    @objc private func addYourTopicButtonTapped() {
        // Rely on the cached premium flag. The cache is refreshed on launch and by the
        // Transaction.updates listener; doing another await here can hang for many
        // seconds when StoreKit can't reach the App Store (e.g. simulator launched via
        // `simctl` without a StoreKit Testing config), and the button looks dead.
        if PremiumIAP.isUnlocked() {
            openAddTopicScreen()
        } else {
            showPaywall()
        }
    }

    // MARK: - Protocol Method

    func reloadInterface() {
        highlightSelectedThemes()
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: MainViewController())
    }

    func updateCustomButtonTitle(to title: String) {
        customThemeTitle = title
        // Update the visible custom button if it exists.
        if let index = visibleThemeKeys.firstIndex(of: "theme_custom") {
            themeButtons[index].setTitle(title, for: .normal)
        }
    }

    private func openAddTopicScreen() {
        let vc = AddTopicViewController()
        let presenter = AddTopicPresenter(
            view: vc,
            delegate: self,
            language: LanguageManager.shared.currentLanguage.rawValue
        )
        vc.presenter = presenter
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showPaywall() {
        let paywallVC = PaywallViewController()
        paywallVC.onPurchaseSuccess = { [weak self] in
            self?.openAddTopicScreen()
        }
        let nav = UINavigationController(rootViewController: paywallVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

extension ThemesViewController: AddTopicDelegate {
    func didCreateTopic(name: String, words: [String], language: String) {
        updateCustomTheme(with: words)
        presenter?.deselectAllThemes()
        presenter?.selectTheme(named: "theme_custom")
        updateCustomButtonTitle(to: name)
        onCustomThemeSet?(name)
        highlightSelectedThemes()
        UserDefaults.standard.set(name, forKey: "custom_theme_title")
    }
}
