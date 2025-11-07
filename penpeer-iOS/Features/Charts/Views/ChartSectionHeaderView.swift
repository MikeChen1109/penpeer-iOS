import UIKit

final class ChartSectionHeaderView: UICollectionReusableView {
    static let reuseID = "ChartSectionHeaderView"

    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var actionHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, showsAction: Bool, action: (() -> Void)?) {
        titleLabel.text = title
        actionButton.isHidden = !showsAction
        actionHandler = action
    }

    @objc private func didTapAction() {
        actionHandler?()
    }

    private func configure() {
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)

        actionButton.setTitle("See All ›", for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, actionButton])
        stack.axis = .horizontal
        stack.alignment = .center

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
}
