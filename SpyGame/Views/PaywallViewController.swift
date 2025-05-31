import UIKit
import StoreKit

final class PaywallViewController: UIViewController {
    
    // MARK: - Callback
    var onPurchaseSuccess: (() -> Void)?
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "full_version".localized
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "unlock_word_generation".localized // Локализуй как "Открой генерацию тем"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("buy_button_title".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("restore_purchase".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        animateEntrance()
        
        purchaseButton.addTarget(self, action: #selector(purchaseTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        
        
        StoreKitTestLogger.fetchProducts(with: ["wordgen_premium"])
        
        
    }
    
    // MARK: - Layout
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, purchaseButton, restoreButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        purchaseButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            purchaseButton.widthAnchor.constraint(equalToConstant: 220),
            purchaseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func animateEntrance() {
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
            self.view.alpha = 1
            self.view.transform = .identity
        }
    }
    
    // MARK: - Purchase
    @objc private func purchaseTapped() {
        Task { await purchaseWordgenPremium() }
    }
    
    @MainActor
    private func purchaseWordgenPremium() async {
        do {
            let products = try await Product.products(for: ["wordgen_premium"])
            guard let product = products.first else {
                return
            }
            
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    unlockPremium()
                }
            case .userCancelled:
                break
            default:
                break
            }
        } catch {
            
        }
    }
    
    
    // MARK: - Restore
    @objc private func restoreTapped() {
        Task { await restorePurchase() }
    }
    
    @MainActor
    private func restorePurchase() async {
        do {
            try await AppStore.sync()
            
            guard let product = try await Product.products(for: ["wordgen_premium"]).first else { return }
            if let transaction = await Transaction.latest(for: product.id),
               case .verified = transaction {
                unlockPremium()
            }
        } catch {
            
        }
    }
    
    
    // MARK: - Unlock
    private func unlockPremium() {
        UserDefaults.standard.set(true, forKey: "fullVersionUnlocked")
        dismiss(animated: true) {
            self.onPurchaseSuccess?()
        }
    }
}
