import UIKit
struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

protocol AddTopicDelegate: AnyObject {
    func didCreateTopic(name: String, words: [String], language: String)
    func updateCustomButtonTitle(to title: String)
}
protocol AddTopicViewProtocol: AnyObject {
    func updateRequestInfo(remaining: Int)
    func showGeneratedWords(_ words: [String])
    func showAlert(title: String, message: String)
    func close()
}

class AddTopicViewController: UIViewController, AddTopicViewProtocol  {
    
    var presenter: AddTopicPresenterProtocol!
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .screenshot20250409At101528Pm)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGreen
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topicTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "add_Your_Topic".localized
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("request".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let requestInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = "topic_hint".localized
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var selectedLanguage: String = LanguageManager.shared.currentLanguage.rawValue
    
    private var generatedWords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        setupUI()
        presenter.viewDidLoad()
        setupActions()
        topicTextField.delegate = self
        hideKeyboardWhenTappedAround()
        overrideUserInterfaceStyle = .light
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard cardView.bounds.width > 0, cardView.bounds.height > 0 else {
            
            return
        }
        
        cardView.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        generateButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        saveButton.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }
    
    private func setupUI() {
        view.addSubview(backgroundImage)
        view.addSubview(cardView)
        cardView.addSubview(topicTextField)
        cardView.addSubview(generateButton)
        cardView.addSubview(requestInfoLabel)
        cardView.addSubview(instructionLabel)
        cardView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 340),
            cardView.heightAnchor.constraint(equalToConstant: 600),
            
            topicTextField.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 100),
            topicTextField.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            topicTextField.widthAnchor.constraint(equalToConstant: 260),
            topicTextField.heightAnchor.constraint(equalToConstant: 40),
            
            generateButton.topAnchor.constraint(equalTo: topicTextField.bottomAnchor, constant: 30),
            generateButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            generateButton.widthAnchor.constraint(equalToConstant: 200),
            generateButton.heightAnchor.constraint(equalToConstant: 44),
            
            requestInfoLabel.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 10),
            requestInfoLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            requestInfoLabel.widthAnchor.constraint(equalToConstant: 260),
            requestInfoLabel.heightAnchor.constraint(equalToConstant: 20),
            
            instructionLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            instructionLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            instructionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor,constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor,constant: -40),
            
            saveButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30),
            saveButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
    }
    
    @objc private func generateButtonTapped() {
        presenter.didTapGenerate(topic: topicTextField.text)
    }
    
    func updateRequestInfo(remaining: Int) {
        requestInfoLabel.text = "requests_remaining".localized(with: remaining)
    }
    
    
    @objc func didTapSave() {
        presenter.didTapSave(topic: topicTextField.text)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func close() {
        navigationController?.popViewController(animated: true)
    }
    func showGeneratedWords(_ words: [String]) {
        self.generatedWords = words
    }
    
}
extension String {
    func localized(with arguments: CVarArg...) -> String {
        let format = NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle, value: "", comment: "")
        return String(format: format, arguments: arguments)
    }
}
extension Bundle {
    static var localizedBundle: Bundle {
        let selectedLanguage = LanguageManager.shared.currentLanguage.rawValue
        guard let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension AddTopicViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowed = CharacterSet.letters
        return string.rangeOfCharacter(from: allowed.inverted) == nil
    }
}


