import SwiftUI
import UIKit

@MainActor
final class ChartsViewController: UIViewController {
    private enum SectionKind: Int, Hashable {
        case songs
        case albums

        var title: String {
            switch self {
            case .songs:
                return "Songs"
            case .albums:
                return "Albums"
            }
        }
    }

    private struct RankedSong: Hashable {
        let rank: Int
        let song: Song
        let isFavorite: Bool
    }

    private struct RankedAlbum: Hashable {
        let rank: Int
        let album: Album
    }

    private enum Item: Hashable {
        case song(RankedSong)
        case album(RankedAlbum)
    }

    private typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<SectionKind, Item>

    private let viewModel: ChartsViewModel
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private let loadingView = LoadingView()
    private var dataSource: DataSource!
    private var displayedSections: [SectionKind] = []

    init(viewModel: ChartsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func configureUI() {
        title = "Music"
        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureDataSource() {
        collectionView.register(SongChartCell.self, forCellWithReuseIdentifier: SongChartCell.reuseID)
        collectionView.register(AlbumChartCell.self, forCellWithReuseIdentifier: AlbumChartCell.reuseID)
        collectionView.register(
            ChartSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ChartSectionHeaderView.reuseID
        )

        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            switch item {
            case .song(let ranked):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SongChartCell.reuseID,
                    for: indexPath
                ) as? SongChartCell else {
                    return UICollectionViewCell()
                }
                cell.configure(
                    with: ranked.song,
                    rank: ranked.rank,
                    isFavorite: ranked.isFavorite,
                    favoriteAction: { [weak self] in
                        guard let self else { return }
                        self.viewModel.toggleFavoriteSong(for: ranked.song.trackId)
                        self.applySnapshot()
                    }
                )
                return cell
            case .album(let ranked):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AlbumChartCell.reuseID,
                    for: indexPath
                ) as? AlbumChartCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: ranked.album, rank: ranked.rank)
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] _, kind, indexPath -> UICollectionReusableView? in
            guard
                let self,
                kind == UICollectionView.elementKindSectionHeader,
                indexPath.section < self.displayedSections.count,
                let header = self.collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ChartSectionHeaderView.reuseID,
                    for: indexPath
                ) as? ChartSectionHeaderView
            else {
                return nil
            }
            let section = self.displayedSections[indexPath.section]
            header.configure(
                title: section.title,
                showsAction: true,
                action: self.headerAction(for: section)
            )
            return header
        }
    }

    private func loadData() {
        showLoading()
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.load()
            self.hideLoading()
            self.handleState()
            self.applySnapshot()
        }
    }

    private func applySnapshot() {
        var snapshot = Snapshot()
        displayedSections = []

        for section in viewModel.sections {
            switch section {
            case .songs(let songs) where !songs.isEmpty:
                snapshot.appendSections([.songs])
                displayedSections.append(.songs)
                let items = songs.enumerated().map { index, song in
                    Item.song(
                        RankedSong(
                            rank: index + 1,
                            song: song,
                            isFavorite: viewModel.isFavoriteSong(id: song.trackId)
                        )
                    )
                }
                snapshot.appendItems(items, toSection: .songs)
            case .albums(let albums) where !albums.isEmpty:
                snapshot.appendSections([.albums])
                displayedSections.append(.albums)
                let items = albums.enumerated().map { index, album in
                    Item.album(RankedAlbum(rank: index + 1, album: album))
                }
                snapshot.appendItems(items, toSection: .albums)
            default:
                continue
            }
        }

        collectionView.collectionViewLayout.invalidateLayout()
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func handleState() {
        switch viewModel.state {
        case .offline:
            showEmpty(title: "離線", message: "請檢查網路連線。")
        case .failed(let error):
            showEmpty(title: "載入失敗", message: error.localizedDescription)
        case .loading:
            showLoading()
        default:
            hideEmpty()
        }
    }

    private func showLoading() {
        collectionView.backgroundView = loadingView
    }

    private func hideLoading() {
        if collectionView.backgroundView === loadingView {
            collectionView.backgroundView = nil
        }
    }

    private func showEmpty(title: String, message: String) {
        let empty = EmptyStateView(title: title, message: message, actionTitle: "重試") { [weak self] in
            self?.loadData()
        }
        collectionView.backgroundView = empty
    }

    private func hideEmpty() {
        if collectionView.backgroundView is EmptyStateView {
            collectionView.backgroundView = nil
        }
    }

    private func headerAction(for section: SectionKind) -> (() -> Void)? {
        switch section {
        case .songs:
            return { [weak self] in self?.showAllSongs() }
        case .albums:
            return { [weak self] in self?.showComingSoon(for: section.title) }
        }
    }

    private func showAllSongs() {
        let songsVM = SongsListViewModel(term: viewModel.searchTerm)
        let hosting = UIKitHosting.host(SongsListView(viewModel: songsVM))
        navigationController?.pushViewController(hosting, animated: true)
    }

    private func showComingSoon(for title: String) {
        let alert = UIAlertController(
            title: title,
            message: "See All 功能即將推出。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ -> NSCollectionLayoutSection? in
            guard
                let self,
                sectionIndex < self.displayedSections.count
            else {
                return self?.makeSongsSection()
            }
            switch self.displayedSections[sectionIndex] {
            case .songs:
                return self.makeSongsSection()
            case .albums:
                return self.makeAlbumsSection()
            }
        }
    }

    private func makeSongsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.7),
            heightDimension: .estimated(340)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            repeatingSubitem: item, count: 4,
        )
        group.interItemSpacing = .fixed(12)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 24, trailing: 12)
        section.boundarySupplementaryItems = [makeHeaderItem()]
        return section
    }

    private func makeAlbumsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .estimated(220))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .estimated(220))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 24, trailing:12)
        section.interGroupSpacing = 12
        section.boundarySupplementaryItems = [makeHeaderItem()]
        return section
    }

    private func makeHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
