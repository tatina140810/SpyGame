import UIKit
import SnapKit

protocol MainViewProtocol: AnyObject {
    func navigateToNewGame()
    func navigateToLanguage()
    func navigateToRules()
    func presentPrivacyPolicy()
}
  
class MainViewController: UIViewController, MainViewProtocol {

    var presenter: MainPresenterProtocol!

    private var backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .screenshot20250409At101528Pm)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.8
        return imageView
    }()

    private lazy var newGameButton = makeButton(titleKey: "new_game", action: #selector(handleNewGame))
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        [newGameButton, languageButton, rulesButton].forEach {
            $0.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
        navigationItem.backButtonTitle = ""

        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { $0.edges.equalToSuperview() }

        let buttons = [newGameButton, languageButton, rulesButton, privacyPolicyButton]
        for (index, button) in buttons.enumerated() {
            view.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(50)
                make.width.equalTo(240)
                if index == 0 {
                    make.centerY.equalToSuperview().offset(80)
                } else {
                    make.top.equalTo(buttons[index - 1].snp.bottom).offset(24)
                }
            }
        }
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

    // MARK: - Button Actions

    @objc private func handleNewGame() { presenter.didTapNewGame() }
    @objc private func handleLanguage() { presenter.didTapLanguage() }
    @objc private func handleRules() { presenter.didTapRules() }
    @objc private func handlePrivacy() { presenter.didTapPrivacy() }
   

    // MARK: - MainViewProtocol

    func navigateToNewGame() {
        let presenter = PlayersSetupPresenter()
        let vc = PlayersSetupViewController(presenter: presenter)
        presenter.view = vc
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
