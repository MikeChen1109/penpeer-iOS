import UIKit

final class SearchViewController: UIViewController {
    private let searchBar: UISearchBar = {
        let bar = UISearchBar(frame: .zero)
        bar.searchBarStyle = .minimal
        bar.placeholder = "搜尋歌曲或專輯"
        bar.returnKeyType = .search
        bar.enablesReturnKeyAutomatically = true
        bar.autocapitalizationType = .none
        bar.autocorrectionType = .no
        return bar
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "搜尋你喜歡的歌曲或專輯"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var resultsController: ChartsContentViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSearchBar()
        configureLayout()
        showPlaceholder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }

    private func configureSearchBar() {
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }

    private func configureLayout() {
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showPlaceholder(message: String? = nil) {
        placeholderLabel.text = message ?? "搜尋你喜歡的歌曲或專輯"
        guard placeholderLabel.superview == nil else { return }
        containerView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 24),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -24)
        ])
    }

    private func hidePlaceholder() {
        placeholderLabel.removeFromSuperview()
    }

    private func performSearch(with text: String?) {
        let term = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            removeResults()
            showPlaceholder()
            return
        }

        hidePlaceholder()
        removeResults()

        let viewModel = ChartsViewModel(term: term)
        let controller = ChartsContentViewController(viewModel: viewModel)
        addChild(controller)
        containerView.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        controller.didMove(toParent: self)
        controller.reloadContent()
        resultsController = controller
    }

    private func removeResults() {
        guard let controller = resultsController else { return }
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        resultsController = nil
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch(with: searchBar.text)
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            removeResults()
            showPlaceholder()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        removeResults()
        showPlaceholder()
    }
}
