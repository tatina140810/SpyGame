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
    
    private lazy var newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New Game", for: .normal)
        button.backgroundColor = .clear
        button.setTitle("Новая игра ", for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleNewGameButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var rulesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New Game", for: .normal)
        button.backgroundColor = .clear
        button.setTitle("Правила игры", for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleRulesButtonTapped), for: .touchUpInside)
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
        
        rulesButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }
    
    private func setupUI() {
        view.addSubview(bacgroundImage)
        bacgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(newGameButton)
        newGameButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(240)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(240)
        }
        view.addSubview(rulesButton)
        rulesButton.snp.makeConstraints { make in
            make.top.equalTo(newGameButton.snp.bottom).offset(24)
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
    
    @objc private func handleRulesButtonTapped() {
        let vc = RulesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

