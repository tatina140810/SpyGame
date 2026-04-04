import UIKit
import StoreKit

final class PaywallViewController: UIViewController {

    var onPurchaseSuccess: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "full_version".localized
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "unlock_word_generation".localized
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        animateEntrance()

        purchaseButton.addTarget(self, action: #selector(purchaseTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)

        Task { await prefetchProductsForCaching() }
    }

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

    /// Warms the StoreKit cache so the purchase sheet opens faster.
    private func prefetchProductsForCaching() async {
        do {
            _ = try await PremiumIAP.loadProduct()
        } catch {
            #if DEBUG
            print("[PremiumIAP] prefetch failed: \(error.localizedDescription)")
            #endif
        }
    }

    @objc private func purchaseTapped() {
        Task { await purchaseWordgenPremium() }
    }

    @MainActor
    private func purchaseWordgenPremium() async {
        do {
            let product = try await PremiumIAP.loadProduct()
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                do {
                    let transaction = try PremiumIAP.verifiedTransaction(from: verification)
                    await transaction.finish()
                    unlockPremium()
                } catch {
                    presentStoreAlert(messageKey: "store_purchase_unverified")
                }
            case .userCancelled:
                break
            case .pending:
                presentStoreAlert(messageKey: "store_purchase_pending")
            @unknown default:
                presentStoreAlert(messageKey: "store_purchase_failed")
            }
        } catch PremiumIAP.PremiumIAPError.productUnavailable {
            presentStoreAlert(messageKey: "store_product_unavailable")
        } catch {
            presentStoreAlert(messageKey: "store_purchase_failed")
        }
    }

    @objc private func restoreTapped() {
        Task { await restorePurchase() }
    }

    @MainActor
    private func restorePurchase() async {
        do {
            try await AppStore.sync()
            if await PremiumIAP.hasVerifiedEntitlement() {
                unlockPremium()
                return
            }
            let product = try await PremiumIAP.loadProduct()
            if let latest = await Transaction.latest(for: product.id) {
                switch latest {
                case .verified:
                    unlockPremium()
                case .unverified:
                    presentStoreAlert(messageKey: "store_purchase_unverified")
                }
            } else {
                presentStoreAlert(messageKey: "store_restore_nothing_found")
            }
        } catch {
            presentStoreAlert(messageKey: "store_restore_failed")
        }
    }

    private func unlockPremium() {
        UserDefaults.standard.unlockFullVersion()
        dismiss(animated: true) {
            self.onPurchaseSuccess?()
        }
    }

    private func presentStoreAlert(messageKey: String) {
        let alert = UIAlertController(
            title: "error".localized,
            message: messageKey.localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "done".localized, style: .default))
        present(alert, animated: true)
    }
}
