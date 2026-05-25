import UIKit

final class RoomSetupViewController: UIViewController {

    // MARK: - UI

    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .background)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.8
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "play_together".localized
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private lazy var createRoomBanner: UIView = makeBanner(
        titleKey: "create_room",
        symbolName: "person.crop.circle.badge.plus",
        action: #selector(handleCreateRoom)
    )

    private lazy var joinRoomBanner: UIView = makeBanner(
        titleKey: "join_room",
        symbolName: "person.3.fill",
        action: #selector(handleJoinRoom)
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = ""
        setupUI()
        installAdBanner()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createRoomBanner.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
        joinRoomBanner.applyNeonGradient(borderColor: .lightBlue, innerColor: .darkGreen)
    }

    // MARK: - Layout

    private func setupUI() {
        [backgroundImage, titleLabel, createRoomBanner, joinRoomBanner].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            createRoomBanner.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            createRoomBanner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createRoomBanner.widthAnchor.constraint(equalToConstant: 300),
            createRoomBanner.heightAnchor.constraint(equalToConstant: 180),

            joinRoomBanner.topAnchor.constraint(equalTo: createRoomBanner.bottomAnchor, constant: 30),
            joinRoomBanner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            joinRoomBanner.widthAnchor.constraint(equalToConstant: 300),
            joinRoomBanner.heightAnchor.constraint(equalToConstant: 180)
        ])
    }

    private func makeBanner(titleKey: String, symbolName: String, action: Selector) -> UIView {
        let container = UIView()
        container.backgroundColor = .darkGreen
        container.layer.cornerRadius = 20

        let iconImageView = UIImageView(image: UIImage(systemName: symbolName))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = titleKey.localized
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconImageView, label])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60)
        ])

        let tap = UITapGestureRecognizer(target: self, action: action)
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(tap)

        return container
    }

    // MARK: - Actions

    @objc private func handleCreateRoom() {
        let vc = HostRoomViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleJoinRoom() {
        let vc = GuestRoomViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
