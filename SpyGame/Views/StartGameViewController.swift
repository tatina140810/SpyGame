import UIKit
import SnapKit

protocol StartGameViewProtocol: AnyObject {
    func showFrontCard(withInstruction text: String)
    func showWordCard(withWord word: String)
    func showSpyCard()
    func navigateToTimer(time: Int)
}
class StartGameViewController: UIViewController, StartGameViewProtocol  {
    private var presenter: StartGamePresenter!
    private var isFlipped = false
    
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
    private var frontStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 2
        stackView.layer.borderColor = UIColor.white.cgColor
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 30, left: 20, bottom: 0, right: 20)
        
        return stackView
    }()
    private var backStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 2
        stackView.layer.borderColor = UIColor.white.cgColor
        stackView.isHidden = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        return stackView
    }()
    private var spyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 2
        stackView.layer.borderColor = UIColor.red.cgColor
        stackView.isHidden = true
        return stackView
    }()
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
    private let spykWordLabel: UILabel = {
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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        guard let settings = UserDefaults.standard.loadGameSettings() else {
            fatalError("⚠️ GameSettings не найдены")
        }

        let selectedThemes = allThemes.filter { settings.selectedThemeNames.contains($0.nameKey) }
        let selectedWords = selectedThemes.flatMap { $0.words }.shuffled()

        self.presenter = StartGamePresenter(
            view: self,
            playersCount: settings.playersCount,
            spyCount: settings.spyCount,
            selectedWords: selectedWords,
            time: settings.selectedTime
        )
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        setupUI()
        
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
        view.addSubview(bacgroundImage)
        bacgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(600)
            make.width.equalTo(340)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
        cardView.isUserInteractionEnabled = true
        cardView.addGestureRecognizer(tapGesture)
        
        cardView.addSubview(frontStackView)
        frontStackView.addArrangedSubview(frontImage)
        frontStackView.addArrangedSubview(frontLabel)
        cardView.addSubview(backStackView)
        backStackView.addArrangedSubview(backWordLabel)
        backStackView.addArrangedSubview(backLabel)
        cardView.addSubview(spyStackView)
        spyStackView.addArrangedSubview(spykWordLabel)
        spyStackView.addArrangedSubview(spyBackLabel )
        frontStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        backStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        spyStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
    }
    
    @objc private func handleCardTap() {
        presenter.handleCardTap()
    }
    
    // MARK: - View Protocol Methods
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
