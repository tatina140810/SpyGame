import UIKit

protocol PlayersSetupViewProtocol: AnyObject {
    func updatePlayersCountLabel(_ count: Int)
    func updateSpyCountLabel(_ count: Int)
    func handleStartButtonTapped()
    func navigateToGame(playersCount: Int,
                        spyCount: Int,
                        selectedThemes: [Theme],
                        selectedTime: Int,
                        words: [String])
    
    func showAlert(message: String)
    func toggleThemeSelection(for button: UIButton, isSelected: Bool)
    func highlightedSelectedTime(seconds: Int)
}

class PlayersSetupViewController: UIViewController, PlayersSetupViewProtocol {
    
    
    var presenter: PlayersSetupProtocol?
    
    init(presenter: PlayersSetupProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.presenter = presenter
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var themeButtons: [UIButton] = []
    var timeButtons: [UIButton] = []
    private let allThemes: [String] = [
        "theme_food",
        "theme_animals",
        "theme_jobs",
        "theme_transport",
        "theme_movies",
        "theme_travel",
    ]
    
    
    private var backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .screenshot20250409At101528Pm)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.8
        return imageView
    }()
    private var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGreen
        view.layer.cornerRadius = 20
        return view
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        return stackView
    }()
    private var playersStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top:0, left: 70, bottom:0, right: 70)
        
        return stackView
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.text = "game_settings".localized
        return label
    }()
    private var playersLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "players_count:".localized
        return label
    }()
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .white
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    private var playersCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    private lazy var minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .white
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        return button
    }()
    private var spyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 70)
        
        return stackView
    }()
    private var firstLineThemesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        return stackView
    }()
    private var secondLineThemesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        
        return stackView
    }()
    private var thirdLineThemesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        
        return stackView
    }()
    private var spyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "spies_count:".localized
        return label
    }()
    private lazy var plusSpyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .white
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(plusSpyButtonTapped), for: .touchUpInside)
        return button
    }()
    private var spyCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.text = "1"
        return label
    }()
    private lazy var minusSpyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .white
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(minusSpyButtonTapped), for: .touchUpInside)
        return button
    }()
    private var timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        
        return stackView
    }()
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "time:".localized
        return label
    }()
    private lazy var oneMinutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("minute_1".localized, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(oneMinutButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var twoMinutsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("minute_2".localized, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(twoMinutsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var threeMinutsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("minute_3".localized, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(threeMinutsButtonTapped), for: .touchUpInside)
        return button
    }()
    private func makeThemeButton(titleKey: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(titleKey.localized, for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private lazy var allThemesButton = makeThemeButton(titleKey: "all_themes", action: #selector(allThemesButtonTapped))
    
    private var themeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "category_selection:".localized
        return label
    }()
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("new_game".localized, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleStartButtonTapped), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        presenter = PlayersSetupPresenter(view: self)
        setupUI()
        applySavedSettings()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "questionmark.app"),
            style: .plain,
            target: self,
            action: #selector(rulesButtonTapped)
        )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        
    }
    private func setupUI() {
        [backgroundImage, startButton, cardView, stackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(startButton)
        NSLayoutConstraint.activate([
            startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 240)
        ])
        
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 600),
            cardView.widthAnchor.constraint(equalToConstant: 340)
        ])
        
        cardView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -55),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(playersLabel)
        stackView.addArrangedSubview(playersStackView)
        stackView.addArrangedSubview(spyLabel)
        stackView.addArrangedSubview(spyStackView)
        stackView.addArrangedSubview(themeLabel)
        stackView.addArrangedSubview(allThemesButton)
        stackView.addArrangedSubview(firstLineThemesStackView)
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(timeStackView)
        
        playersStackView.addArrangedSubview(minusButton)
        playersStackView.addArrangedSubview(playersCountLabel)
        playersStackView.addArrangedSubview(plusButton)
        
        spyStackView.addArrangedSubview(minusSpyButton)
        spyStackView.addArrangedSubview(spyCountLabel)
        spyStackView.addArrangedSubview(plusSpyButton)
        
        firstLineThemesStackView.addArrangedSubview(allThemesButton)
        
        timeStackView.addArrangedSubview(oneMinutButton)
        timeStackView.addArrangedSubview(twoMinutsButton)
        timeStackView.addArrangedSubview(threeMinutsButton)
        
        themeButtons = [
            allThemesButton
        ]
        
        timeButtons = [oneMinutButton, twoMinutsButton, threeMinutsButton]
    }
    
    @objc private func rulesButtonTapped() {
        let vc = RulesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func settingsButtonTapped() {
        let mainVC = MainViewController()
        let presenter = MainPresenter(view: mainVC)
        mainVC.presenter = presenter
        navigationController?.setViewControllers([mainVC], animated: true)
    }
    
    @objc private func plusButtonTapped() {
        presenter?.increasePlayers()
    }
    @objc private func minusButtonTapped() {
        presenter?.decreasePlayers()
    }
    @objc private func plusSpyButtonTapped() {
        presenter?.increaseSpies()
    }
    @objc private func minusSpyButtonTapped() {
        presenter?.decreaseSpies()
    }
    @objc private func allThemesButtonTapped() {
        
        
        presenter?.updateSelectedThemes(allThemes)
        
        themeButtons.forEach {
            presenter?.toggleThemeSelection(for: $0, isSelected: true)
        }
        let themesVC = ThemesViewController()
        themesVC.shouldSelectAllThemes = true
        themesVC.onThemesSelected = { [weak self] selectedThemes in
            self?.presenter?.updateSelectedThemes(selectedThemes)
        }
        navigationController?.pushViewController(themesVC, animated: true)
    }
    
    @objc internal func handleStartButtonTapped() {
        presenter?.startGame()
    }
    @objc private func oneMinutButtonTapped() {
        presenter?.setGameTime(60)
        updateSelectedTimeButton(selectedButton: oneMinutButton)
    }
    
    @objc private func twoMinutsButtonTapped() {
        presenter?.setGameTime(120)
        updateSelectedTimeButton(selectedButton: twoMinutsButton)
    }
    
    @objc private func threeMinutsButtonTapped() {
        presenter?.setGameTime(180)
        updateSelectedTimeButton(selectedButton: threeMinutsButton)
    }
    
    func updatePlayersCountLabel(_ count: Int){
        
        playersCountLabel.text = "\(count)"
    }
    func updateSpyCountLabel(_ count: Int){
        spyCountLabel.text = "\(count)"
    }
    func navigateToGame(playersCount: Int,
                        spyCount: Int,
                        selectedThemes: [Theme],
                        selectedTime: Int,
                        words: [String]) {
        let settings = GameSettings(
            playersCount: playersCount,
            spyCount: spyCount,
            selectedThemeNames: selectedThemes.map { $0.nameKey },
            selectedTime: selectedTime
        )
        UserDefaults.standard.saveGameSettings(settings)
        
        let vc = StartGameViewController(words: words)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func updateSelectedTimeButton(selectedButton: UIButton) {
        let buttons = [oneMinutButton, twoMinutsButton, threeMinutsButton]
        
        buttons.forEach {
            $0.backgroundColor = .clear
            $0.setTitleColor(.white, for: .normal)
            $0.layer.borderColor = UIColor.white.cgColor
        }
        
        selectedButton.backgroundColor = .white
        selectedButton.setTitleColor(.darkGreen, for: .normal)
        selectedButton.layer.borderColor = UIColor.darkGreen.cgColor
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    func toggleThemeSelection(for button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = .white
            button.setTitleColor(.darkGreen, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
        }
    }
    
    private func timeKey(for button: UIButton) -> String? {
        switch button {
        case oneMinutButton: return "minute_1"
        case twoMinutsButton: return "minute_2"
        case threeMinutsButton: return "minute_3"
        default: return nil
        }
    }
    private func applySavedSettings() {
        guard let settings = UserDefaults.standard.loadGameSettings() else { return }
        
        //   highlightSelectedThemes(named: settings.selectedThemeNames)
        
        switch settings.selectedTime {
        case 60:
            updateSelectedTimeButton(selectedButton: oneMinutButton)
        case 120:
            updateSelectedTimeButton(selectedButton: twoMinutsButton)
        case 180:
            updateSelectedTimeButton(selectedButton: threeMinutsButton)
        default:
            break
        }
    }
    
    func highlightedSelectedTime(seconds: Int) {
        let selectedButton: UIButton?
        
        switch seconds {
        case 60:
            selectedButton = oneMinutButton
        case 120:
            selectedButton = twoMinutsButton
        case 180:
            selectedButton = threeMinutsButton
        default:
            selectedButton = nil
        }
        
        if let button = selectedButton {
            updateSelectedTimeButton(selectedButton: button)
        }
    }
}





