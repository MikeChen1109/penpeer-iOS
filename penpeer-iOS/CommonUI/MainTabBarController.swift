import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
    }

    private func configureTabs() {
        let chartsViewModel = ChartsViewModel()
        let charts = ChartsViewController(viewModel: chartsViewModel)
        let chartsNav = UINavigationController(rootViewController: charts)
        chartsNav.tabBarItem = UITabBarItem(
            title: "Music",
            image: UIImage(systemName: "music.note.list"),
            selectedImage: UIImage(systemName: "music.note.list")
        )

        let search = SearchPlaceholderViewController()
        let searchNav = UINavigationController(rootViewController: search)
        searchNav.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        setViewControllers([chartsNav, searchNav], animated: false)
    }
}
