import UIKit

final class SearchPlaceholderViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground
        configurePlaceholder()
    }

    private func configurePlaceholder() {
        let label = UILabel()
        label.text = "Search 功能建置中"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
}
