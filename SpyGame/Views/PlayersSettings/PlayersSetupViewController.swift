import UIKit
import SnapKit

protocol PlayersSetupViewProtocol: AnyObject {
    func updatePlayersCountLabel(_ count: Int)
    func updateSpyCountLabel(_ count: Int)
    func handleStartButtonTapped()
    func navigateToGame(playersCount: Int, spyCount: Int, selectedThemes: [Theme], selectedTime: Int)
    func showAlert(message: String)
    func toggleThemeSelection(for button: UIButton, isSelected: Bool)
    func highlightSelectedThemes(named: [String])
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
        stackView.spacing = 5
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
    private lazy var foodThemesButton = makeThemeButton(titleKey: "food", action: #selector(foodThemesButtonTapped))
    private lazy var animalsThemesButton = makeThemeButton(titleKey: "animals", action: #selector(animalsThemesButtonTapped))
    private lazy var jobsThemesButton = makeThemeButton(titleKey: "jobs", action: #selector(jobsThemesButtonTapped))
    private lazy var transportThemesButton = makeThemeButton(titleKey: "transport", action: #selector(transportThemesButtonTapped))
    private lazy var moviesThemesButton = makeThemeButton(titleKey: "movies", action: #selector(moviesThemesButtonTapped))
    private lazy var surrealThemesButton = makeThemeButton(titleKey: "surreal", action: #selector(surrealThemesButtonTapped))
    private lazy var adaultsThemesButton = makeThemeButton(titleKey: "adult", action: #selector(adaultsThemesButtonTapped))
    
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
        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(240)
        }
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(600)
            make.width.equalTo(340)
        }
        cardView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(15)
        }
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(playersLabel)
        stackView.addArrangedSubview(playersStackView)
        stackView.addArrangedSubview(spyLabel)
        stackView.addArrangedSubview(spyStackView)
        
        stackView.addArrangedSubview(themeLabel)
        stackView.addArrangedSubview(allThemesButton)
        stackView.addArrangedSubview(firstLineThemesStackView)
        stackView.addArrangedSubview(secondLineThemesStackView)
        stackView.addArrangedSubview(thirdLineThemesStackView)
        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(timeStackView)
        
        playersStackView.addArrangedSubview(minusButton)
        playersStackView.addArrangedSubview(playersCountLabel)
        playersStackView.addArrangedSubview(plusButton)
        
        spyStackView.addArrangedSubview(minusSpyButton)
        spyStackView.addArrangedSubview(spyCountLabel)
        spyStackView.addArrangedSubview(plusSpyButton)
        
        firstLineThemesStackView.addArrangedSubview(allThemesButton)
        firstLineThemesStackView.addArrangedSubview(foodThemesButton)
        firstLineThemesStackView.addArrangedSubview(animalsThemesButton)
        
        secondLineThemesStackView.addArrangedSubview(adaultsThemesButton)
        secondLineThemesStackView.addArrangedSubview(transportThemesButton)
        secondLineThemesStackView.addArrangedSubview(moviesThemesButton)
        
        thirdLineThemesStackView.addArrangedSubview(surrealThemesButton)
        thirdLineThemesStackView.addArrangedSubview(jobsThemesButton)
        
        timeStackView.addArrangedSubview(oneMinutButton)
        timeStackView.addArrangedSubview(twoMinutsButton)
        timeStackView.addArrangedSubview(threeMinutsButton)
        themeButtons = [
            allThemesButton, foodThemesButton, animalsThemesButton,
            adaultsThemesButton, transportThemesButton, moviesThemesButton,
            surrealThemesButton, jobsThemesButton
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
        presenter?.selectAllThemes(from: allThemes)
        
        let allButtons = [
            foodThemesButton, animalsThemesButton, transportThemesButton,
            jobsThemesButton, moviesThemesButton, surrealThemesButton, adaultsThemesButton
        ]
        
        allButtons.forEach {
            presenter?.toggleThemeSelection(for: $0, isSelected: true)
        }
    }
    
    @objc private func foodThemesButtonTapped(){
        presenter?.selectTheme(named: "theme_food")
        let isSelected = foodThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: foodThemesButton, isSelected: isSelected)
    }
    
    @objc private func animalsThemesButtonTapped(){
        presenter?.selectTheme(named: "theme_animals")
        let isSelected = animalsThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: animalsThemesButton, isSelected: isSelected)
    }
    
    @objc private func transportThemesButtonTapped(){
        presenter?.selectTheme(named: "theme_transport")
        let isSelected = transportThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: transportThemesButton, isSelected: isSelected)
    }
    
    @objc private func jobsThemesButtonTapped() {
        presenter?.selectTheme(named: "theme_jobs")
        let isSelected = jobsThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: jobsThemesButton, isSelected: isSelected)
    }
    
    @objc private func moviesThemesButtonTapped() {
        presenter?.selectTheme(named: "theme_movies")
        let isSelected = moviesThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: moviesThemesButton, isSelected: isSelected)
    }
    
    @objc private func surrealThemesButtonTapped() {
        presenter?.selectTheme(named: "theme_surreal")
        let isSelected = surrealThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: surrealThemesButton, isSelected: isSelected)
    }
    
    @objc private func adaultsThemesButtonTapped() {
        presenter?.selectTheme(named: "theme_adult")
        let isSelected = adaultsThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: adaultsThemesButton, isSelected: isSelected)
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
    
    func navigateToGame(playersCount: Int, spyCount: Int, selectedThemes: [Theme], selectedTime: Int) {
        let settings = GameSettings(
            playersCount: playersCount,
            spyCount: spyCount,
            selectedThemeNames: selectedThemes.map { $0.nameKey },
            selectedTime: selectedTime
        )
        UserDefaults.standard.saveGameSettings(settings)
        
        let vc = StartGameViewController()
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
    private func themeKey(for button: UIButton) -> String? {
        switch button {
        case foodThemesButton: return "theme_food"
        case animalsThemesButton: return "theme_animals"
        case transportThemesButton: return "theme_transport"
        case jobsThemesButton: return "theme_jobs"
        case moviesThemesButton: return "theme_movies"
        case surrealThemesButton: return "theme_surreal"
        case adaultsThemesButton: return "theme_adult"
        default: return nil
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

        // 🔘 Отметить выбранные темы
        highlightSelectedThemes(named: settings.selectedThemeNames)

        // ⏱️ Отметить выбранное время
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


    func highlightSelectedThemes(named selectedNames: [String]) {
        for button in themeButtons {
            
            guard let titleKey = themeKey(for: button) else { continue }
            
            let isSelected = selectedNames.contains(titleKey)
            presenter?.toggleThemeSelection(for: button, isSelected: isSelected)
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

    
    


