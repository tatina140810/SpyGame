import UIKit
import SnapKit

class MainViewController: UIViewController {
    private var bacgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .screenshot20250409At101528Pm)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.8
        return imageView
    }()
    private lazy var languageButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("language_selection".localized, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handlelanguageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("new_game".localized, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleNewGameButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var rulesButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("rules".localized, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleRulesButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var privacyPolicyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setTitle("privacy_policy".localized, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(privacyPolicyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        setupUI()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        newGameButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        languageButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        rulesButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }
    
    private func setupUI() {
        view.addSubview(bacgroundImage)
        bacgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(newGameButton)
        newGameButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(150)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(240)
        }
        view.addSubview(languageButton)
        languageButton.snp.makeConstraints { make in
            make.top.equalTo(newGameButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(240)
        }
        view.addSubview(rulesButton)
        rulesButton.snp.makeConstraints { make in
            make.top.equalTo(languageButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(240)
        }
        view.addSubview(privacyPolicyButton)
        privacyPolicyButton.snp.makeConstraints { make in
            make.top.equalTo(rulesButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(240)
        }
    }
    
    @objc private func handleNewGameButtonTapped() {
        let presenter = PlayersSetupPresenter()
        let vc = PlayersSetupViewController(presenter: presenter)
        presenter.view = vc
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc private func handlelanguageButtonTapped() {
        let vc = LanguageViewController()
        vc.presenter = LanguagePresenter(view: vc)
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func handleRulesButtonTapped() {
        let vc = RulesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func privacyPolicyButtonTapped(){
        let vc = PrivacyPolicyViewController()
        navigationController?.present(vc, animated: true)
    }
    
}

