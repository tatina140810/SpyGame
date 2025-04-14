import UIKit
import SnapKit

protocol LanguageViewProtocol: AnyObject {
    func updateLanguageButtonStyles(selected: Language)
    func reloadInterface()
}

class LanguageViewController: UIViewController, LanguageViewProtocol {
    private var selectedLanguage: Language = LanguageManager.shared.currentLanguage
    var presenter: LanguagePresenterProtocol?
    
    
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
    
    private lazy var englishLanguageButton: UIButton = makeLanguageButton(title: "English", action: #selector(englishLanguageButtonTapped))
    private lazy var rusianLanguageButton: UIButton = makeLanguageButton(title: "Русский", action: #selector(rusianLanguageButtonTapped))
    private lazy var kyrgyzLanguageButton: UIButton = makeLanguageButton(title: "Кыргызча", action: #selector(kyrgyzLanguageButtonTapped))
    
    private lazy var safeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("apply".localized, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(safeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        presenter?.viewDidLoad()
        setupUI()
        updateLanguageButtonStyles(selected: LanguageManager.shared.currentLanguage)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        
    }
    
    private func setupUI() {
        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(600)
            make.width.equalTo(340)
        }
        
        
        let buttons = [englishLanguageButton, rusianLanguageButton, kyrgyzLanguageButton, safeButton]
        for (index, button) in buttons.enumerated() {
            cardView.addSubview(button)
            button.snp.makeConstraints { make in
                if index == 0 {
                    make.top.equalToSuperview().offset(120)
                } else {
                    make.top.equalTo(buttons[index - 1].snp.bottom).offset(index == 3 ? 50 : 24)
                }
                make.centerX.equalToSuperview()
                make.height.equalTo(50)
                make.width.equalTo(240)
            }
        }
    }
    
    private func makeLanguageButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitleColor(.white, for: .normal)
        button.addTarget(nil, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func englishLanguageButtonTapped() {
        presenter?.didSelectLanguage(.english)
    }
    
    @objc private func rusianLanguageButtonTapped() {
        presenter?.didSelectLanguage(.russian)
    }
    
    @objc private func kyrgyzLanguageButtonTapped() {
        presenter?.didSelectLanguage(.kyrgyz)
    }
    
    @objc private func safeButtonTapped() {
        presenter?.applySelectedLanguage()
        navigationController?.popViewController(animated: true)
    }
    
    func updateLanguageButtonStyles(selected: Language) {
        let buttons: [(UIButton, Language)] = [
            (englishLanguageButton, .english),
            (rusianLanguageButton, .russian),
            (kyrgyzLanguageButton, .kyrgyz)
        ]
        
        for (button, lang) in buttons {
            if lang == selected {
                button.backgroundColor = .white
                button.setTitleColor(.black, for: .normal)
                button.layer.borderColor = UIColor.black.cgColor
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.white, for: .normal)
                button.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    func reloadInterface() {
        let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate
        let newRootVC = MainViewController()
        sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: newRootVC)
    }
}
