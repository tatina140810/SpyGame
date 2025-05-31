import UIKit

protocol ThemesViewControllerProtocol: AnyObject {
    func reloadInterface()
    func updateCustomButtonTitle(to title: String)
    
}

class ThemesViewController: UIViewController, ThemesViewControllerProtocol {
    
    var presenter: ThemesPresenterProtocol?
    var onThemesSelected: (([String]) -> Void)?
    var shouldSelectAllThemes: Bool = false
    
    private var customThemeButton: UIButton?
    var onCustomThemeSet: ((String) -> Void)?
    
    
    private let allThemeKeys = [
        "theme_food", "theme_animals", "theme_jobs",
        "theme_transport", "theme_movies", "theme_travel", "theme_custom"
    ]
    private var customThemeTitle: String = {
        return UserDefaults.standard.string(forKey: "custom_theme_title") ?? "theme_custom".localized
    }()
    
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
    
    private func makeThemeButton(titleKey: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(titleKey.localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }
    
    private lazy var foodThemesButton = makeThemeButton(titleKey: "food", action: #selector(foodThemesButtonTapped))
    private lazy var animalsThemesButton = makeThemeButton(titleKey: "animals", action: #selector(animalsThemesButtonTapped))
    private lazy var jobsThemesButton = makeThemeButton(titleKey: "jobs", action: #selector(jobsThemesButtonTapped))
    private lazy var transportThemesButton = makeThemeButton(titleKey: "transport", action: #selector(transportThemesButtonTapped))
    private lazy var moviesThemesButton = makeThemeButton(titleKey: "movies", action: #selector(moviesThemesButtonTapped))
    private lazy var travelThemesButton = makeThemeButton(titleKey: "travel", action: #selector(travelThemesButtonTapped))
    
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
    
    private func setupUI() {
        [backgroundImage, cardView,
         foodThemesButton, animalsThemesButton, jobsThemesButton,
         transportThemesButton, moviesThemesButton, travelThemesButton,
         safeButton, addYourTopicButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(backgroundImage)
        view.addSubview(cardView)
        
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
        
        let buttons = [foodThemesButton, animalsThemesButton, jobsThemesButton,
                       transportThemesButton, moviesThemesButton, travelThemesButton]
        
        var previous: UIButton? = nil
        for button in buttons {
            cardView.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
                button.widthAnchor.constraint(equalToConstant: 240),
                button.heightAnchor.constraint(equalToConstant: 44)
            ])
            if let prev = previous {
                button.topAnchor.constraint(equalTo: prev.bottomAnchor, constant: 12).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 44).isActive = true
            }
            previous = button
        }
        
        cardView.addSubview(safeButton)
        cardView.addSubview(addYourTopicButton)
        
        NSLayoutConstraint.activate([
            safeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -25),
            safeButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            safeButton.widthAnchor.constraint(equalToConstant: 200),
            safeButton.heightAnchor.constraint(equalToConstant: 44),
            
            addYourTopicButton.bottomAnchor.constraint(equalTo: safeButton.topAnchor, constant: -25),
            addYourTopicButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            addYourTopicButton.widthAnchor.constraint(equalToConstant: 200),
            addYourTopicButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func highlightSelectedThemes() {
        customThemeButton?.removeFromSuperview()
        customThemeButton = nil
        
        var pairs: [(UIButton, String)] = [
            (foodThemesButton, "theme_food"),
            (animalsThemesButton, "theme_animals"),
            (jobsThemesButton, "theme_jobs"),
            (transportThemesButton, "theme_transport"),
            (moviesThemesButton, "theme_movies"),
            (travelThemesButton, "theme_travel")
        ]
        if let customButton = customThemeButton {
            pairs.append((customButton, "theme_custom"))
        }
        
        for (button, key) in pairs {
            let isSelected = presenter?.selectedThemes.contains(key) ?? false
            presenter?.toggleThemeSelection(for: button, isSelected: isSelected)
        }
        
        if let custom = customTheme {
            
            let button = UIButton(type: .system)
            button.setTitle(customThemeTitle, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(customThemeButtonTapped(_:)), for: .touchUpInside)
            button.backgroundColor = .clear
            button.layer.cornerRadius = 20
            button.layer.borderWidth = 1
            button.clipsToBounds = true
            button.layer.borderColor = UIColor.white.cgColor
            
            cardView.addSubview(button)
            customThemeButton = button
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: travelThemesButton.bottomAnchor, constant: 12).isActive = true
            button.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 240).isActive = true
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            let isSelected = presenter?.selectedThemes.contains("theme_custom") ?? false
            updateButtonAppearance(button, isSelected: isSelected)
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
    
    @objc private func foodThemesButtonTapped() { toggle("theme_food", button: foodThemesButton) }
    @objc private func animalsThemesButtonTapped() { toggle("theme_animals", button: animalsThemesButton) }
    @objc private func jobsThemesButtonTapped() { toggle("theme_jobs", button: jobsThemesButton) }
    @objc private func transportThemesButtonTapped() { toggle("theme_transport", button: transportThemesButton) }
    @objc private func moviesThemesButtonTapped() { toggle("theme_movies", button: moviesThemesButton) }
    @objc private func travelThemesButtonTapped() { toggle("theme_travel", button: travelThemesButton) }
    
    @objc private func customThemeButtonTapped(_ sender: UIButton) {
        toggle("theme_custom", button: sender)
    }
    
    private func toggle(_ key: String, button: UIButton) {
        let wasSelected = presenter?.selectedThemes.contains(key) ?? false
        
        if wasSelected {
            presenter?.deselectTheme(named: key)
        } else {
            presenter?.selectTheme(named: key)
        }
        
        let isNowSelected = presenter?.selectedThemes.contains(key) ?? false
        presenter?.toggleThemeSelection(for: button, isSelected: isNowSelected)
    }
    
    
    
    
    @objc private func safeButtonTapped() {
        if let selected = presenter?.selectedThemes {
            
            onThemesSelected?(selected)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addYourTopicButtonTapped() {
        
        Task {
            let isUnlocked = await AppDelegate.checkEntitlements()
            
            if isUnlocked {
                openAddTopicScreen()
            } else {
                showPaywall()
            }
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
        customThemeButton?.setTitle(title, for: .normal)
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
        navigationController?.pushViewController(paywallVC, animated: true)
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




