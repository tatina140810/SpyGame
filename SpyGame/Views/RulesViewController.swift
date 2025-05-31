import UIKit

class RulesViewController: UIViewController {
    
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
    private lazy var rulesTextLabel: UILabel = {
        let label = UILabel()
        label.text = "game_rules_text".localized
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
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
    
    private func setupUI() {
        [backgroundImage, cardView, rulesTextLabel].forEach {
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
            cardView.heightAnchor.constraint(equalToConstant: 630),
            cardView.widthAnchor.constraint(equalToConstant: 340)
        ])
        
        cardView.addSubview(rulesTextLabel)
        NSLayoutConstraint.activate([
            rulesTextLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            rulesTextLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 35),
            rulesTextLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -35)
        ])
    }
    
}

