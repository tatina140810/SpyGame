import UIKit
import SnapKit

class RulesViewController: UIViewController {
    
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
    private lazy var rulesTextLabel: UILabel = {
        let label = UILabel()
        label.text = """
- Всем игрокам даётся одно слово. 
 
- Шпионы не знают слово — только надпись *«Ты шпион»*.  

- Игроки по кругу называют **ассоциации** к слову.  

- Шпионы стараются **не выдать себя**.  

- Если шпионы раскрыты — побеждают игроки.  

- Если шпионы не раскрыты за отведеное время — победа шпионов!  

- Шпион может **угадать слово** в любой момент и сразу победить.

Приятной игры!

"""
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
        cardView.addSubview(rulesTextLabel)
        rulesTextLabel.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.top).offset(40)
            make.leading.trailing.equalToSuperview().inset(35)
        }
    }
}

