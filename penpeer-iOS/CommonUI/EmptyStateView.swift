import UIKit

final class EmptyStateView: UIView {
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let button = UIButton(type: .system)
    private var action: (() -> Void)?

    init(title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.action = action
        super.init(frame: .zero)
        configure(title: title, message: message, actionTitle: actionTitle)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(title: String, message: String, actionTitle: String?) {
        backgroundColor = .systemBackground

        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center

        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        if let actionTitle {
            button.setTitle(actionTitle, for: .normal)
            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        } else {
            button.isHidden = true
        }

        let stack = UIStackView(arrangedSubviews: [titleLabel, messageLabel, button])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8)
        ])
    }

    @objc private func didTapButton() {
        action?()
    }
}
