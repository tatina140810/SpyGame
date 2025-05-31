import UIKit

protocol StartGameViewProtocol: AnyObject {
    func showFrontCard(withInstruction text: String)
    func showWordCard(withWord word: String)
    func showSpyCard()
    func navigateToTimer(time: Int)
    //func showPaywall()
}
class StartGameViewController: UIViewController, StartGameViewProtocol  {
    var presenter: StartGamePresenter?
    private var isFlipped = false
    var words: [String]
    
    init(words: [String]) {
        self.words = words
        super.init(nibName: nil, bundle: nil)
        
        UserDefaults.standard.set(words, forKey: "last_selected_words")
        
        guard let settings = UserDefaults.standard.loadGameSettings() else {
            fatalError("⚠️ GameSettings не найдены")
        }
        
        self.presenter = StartGamePresenter(
            view: self,
            playersCount: settings.playersCount,
            spyCount: settings.spyCount,
            selectedWords: words,
            time: settings.selectedTime
        )
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var availableWords: [String] = []
    
    
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
    
    private var frontStackView = makeStackView(borderColor: .white)
    private var backStackView = makeStackView(borderColor: .white, isHidden: true)
    private var spyStackView = makeStackView(borderColor: .red, isHidden: true)
    
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
    
    private let backWordLabel: UILabel = {
        let label = UILabel()
        label.text = "word".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textAlignment = .center
        
        label.numberOfLines = 0
        return label
    }()
    private let backLabel: UILabel = {
        let label = UILabel()
        label.text = "word_instruction_next".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        
        label.numberOfLines = 0
        return label
    }()
    private let spyWordLabel: UILabel = {
        let label = UILabel()
        label.text = "you_are_spy".localized
        label.textColor = .red
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.textAlignment = .center
        
        label.numberOfLines = 0
        return label
    }()
    private let spyBackLabel: UILabel = {
        let label = UILabel()
        label.text = "word_instruction_next".localized
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        setupUI()
        
        availableWords = words.shuffled()
        
        // 🔥 Создаём presenter только здесь и на основе переданных `words`
        guard let settings = UserDefaults.standard.loadGameSettings() else {
            fatalError("⚠️ GameSettings не найдены")
        }
        
        presenter = StartGamePresenter(
            view: self,
            playersCount: settings.playersCount,
            spyCount: settings.spyCount,
            selectedWords: availableWords,
            time: settings.selectedTime
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            UserDefaults.standard.clearGameSettings()
        }
    }
    
    private func setupUI() {
        
        [backgroundImage, cardView, frontStackView, backStackView, spyStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 600),
            cardView.widthAnchor.constraint(equalToConstant: 340)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        cardView.isUserInteractionEnabled = true
        cardView.addGestureRecognizer(tapGesture)
        
        frontStackView.addArrangedSubview(frontImage)
        frontStackView.addArrangedSubview(frontLabel)
        cardView.addSubview(frontStackView)
        NSLayoutConstraint.activate([
            frontStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            frontStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            frontStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            frontStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
        
        backStackView.addArrangedSubview(backWordLabel)
        backStackView.addArrangedSubview(backLabel)
        cardView.addSubview(backStackView)
        NSLayoutConstraint.activate([
            backStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            backStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            backStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            backStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
        
        spyStackView.addArrangedSubview(spyWordLabel)
        spyStackView.addArrangedSubview(spyBackLabel)
        cardView.addSubview(spyStackView)
        NSLayoutConstraint.activate([
            spyStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            spyStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            spyStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            spyStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
    }
    
    
    @objc private func handleCardTap() {
        presenter?.handleCardTap()
    }
    
    func showFrontCard(withInstruction text: String) {
        
        frontLabel.text = text
        let fromView = isFlipped ? (backStackView.isHidden ? spyStackView : backStackView) : frontStackView
        let toView = frontStackView
        
        fromView.isHidden = false
        toView.isHidden = false
        
        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.6,
                          options: [.transitionFlipFromLeft, .showHideTransitionViews]) { _ in
            self.isFlipped = false
            self.backStackView.isHidden = true
            self.spyStackView.isHidden = true
            
        }
    }
    func showWordCard(withWord word: String) {
        backWordLabel.text = word
        let fromView = frontStackView
        let toView = backStackView
        
        fromView.isHidden = false
        toView.isHidden = false
        
        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.6,
                          options: [.transitionFlipFromRight, .showHideTransitionViews]) { _ in
            self.isFlipped = true
            self.frontStackView.isHidden = true
            self.spyStackView.isHidden = true
            
        }
    }
    func showSpyCard() {
        let fromView = frontStackView
        let toView = spyStackView
        
        fromView.isHidden = false
        toView.isHidden = false
        
        UIView.transition(from: fromView,
                          to: toView,
                          duration: 0.6,
                          options: [.transitionFlipFromRight, .showHideTransitionViews]) { _ in
            self.isFlipped = true
            self.frontStackView.isHidden = true
            self.backStackView.isHidden = true
        }
    }
    
    func navigateToTimer(time: Int) {
        let timerVC = TimerViewController(time: time)
        let presenter = TimerPresenter(view: timerVC, time: time)
        timerVC.presenter = presenter
        navigationController?.pushViewController(timerVC, animated: true)
    }
}
