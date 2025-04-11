import UIKit
import SnapKit

protocol PlayersSetupViewProtocol: AnyObject {
    func updatePlayersCountLabel(_ count: Int)
    func updateSpyCountLabel(_ count: Int)
    func handleStartButtonTapped()
    func navigateToGame(playersCount: Int, spyCount: Int, selectedThemes: [Theme], selectedTime: Int)
    func showAlert(message: String)
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
    
    
    private var bacgroundImage: UIImageView = {
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
        stackView.spacing = 3
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
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
        label.text = "Настройка игры"
        return label
    }()
    private var playersLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Количество игроков:"
        return label
    }()
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.backgroundColor = .clear
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
        button.setTitle("-", for: .normal)
        button.backgroundColor = .clear
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
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        return stackView
    }()
    private var secondLineThemesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        return stackView
    }()
    private var thirdLineThemesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        return stackView
    }()
    private var spyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Количество шпионов:"
        return label
    }()
    private lazy var plusSpyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.backgroundColor = .clear
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
        button.setTitle("-", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(minusSpyButtonTapped), for: .touchUpInside)
        return button
    }()
    private var timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        return stackView
    }()
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Время:"
        return label
    }()
    private lazy var oneMinutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1 минутa", for: .normal)
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
        button.setTitle("2 минуты", for: .normal)
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
        button.setTitle("3 минуты", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(threeMinutsButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var allThemesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Все темы", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(allThemesButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var foodThemesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Eда", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(foodThemesButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var animalsThemesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Животные", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(animalsThemesButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var jobsThemesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Профессии", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(jobsThemesButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var transportThemesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Транспорт", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(transportThemesButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var moviesThemesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Кино", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(moviesThemesButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var surrealThemesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сюрреализм", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(surrealThemesButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var adaultsThemesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("18+", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(adaultsThemesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var themeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Выбор категорий:"
        return label
    }()
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New Game", for: .normal)
        button.backgroundColor = .clear
        button.setTitle("Нaчать игру", for: .normal)
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
        updateSelectedTimeButton(selectedButton: oneMinutButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
               image: UIImage(systemName: "questionmark.app"),
               style: .plain,
               target: self,
               action: #selector(rulesButtonTapped)
           )
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        
    }
    private func setupUI() {
        view.addSubview(bacgroundImage)
        bacgroundImage.snp.makeConstraints { make in
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
            make.edges.equalToSuperview()
        }
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(playersLabel)
        stackView.addArrangedSubview(playersStackView)
        stackView.addArrangedSubview(spyLabel)
        stackView.addArrangedSubview(spyStackView)
        
        stackView.addArrangedSubview(timeStackView)
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
        
    }
    @objc private func rulesButtonTapped() {
        let vc = RulesViewController()
        navigationController?.pushViewController(vc, animated: true)
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
        presenter?.selectTheme(named: "Еда")
        let isSelected = foodThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: foodThemesButton, isSelected: isSelected)
    }
    
    @objc private func animalsThemesButtonTapped(){
        presenter?.selectTheme(named: "Животные")
        let isSelected = animalsThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: animalsThemesButton, isSelected: isSelected)
    }
    
    @objc private func transportThemesButtonTapped(){
        presenter?.selectTheme(named: "Транспорт")
        let isSelected = transportThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: transportThemesButton, isSelected: isSelected)
    }
    
    @objc private func jobsThemesButtonTapped() {
        presenter?.selectTheme(named: "Профессии")
        let isSelected = jobsThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: jobsThemesButton, isSelected: isSelected)
    }
    
    @objc private func moviesThemesButtonTapped() {
        presenter?.selectTheme(named: "Фильмы")
        let isSelected = moviesThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: moviesThemesButton, isSelected: isSelected)
    }
    
    @objc private func surrealThemesButtonTapped() {
        presenter?.selectTheme(named: "Сюрреализм")
        let isSelected = surrealThemesButton.backgroundColor == .clear
        presenter?.toggleThemeSelection(for: surrealThemesButton, isSelected: isSelected)
    }
    
    @objc private func adaultsThemesButtonTapped() {
        presenter?.selectTheme(named: "18+ Слова")
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
    func updateTime(_ time: String){
        
    }
    
    func navigateToGame(playersCount: Int, spyCount: Int, selectedThemes: [Theme], selectedTime: Int) {
        let vc = StartGameViewController(
            playersCount: playersCount,
            spyCount: spyCount,
            selectedThemes: selectedThemes,
            time: selectedTime
        )
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
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
}

