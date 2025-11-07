import Combine
import Foundation

@MainActor
final class ChartsViewModel {
    enum Section {
        case songs([Song])
        case albums([Album])

        var title: String {
            switch self {
            case .songs:
                return "Songs"
            case .albums:
                return "Albums"
            }
        }

        var count: Int {
            switch self {
            case .songs(let songs):
                return songs.count
            case .albums(let albums):
                return albums.count
            }
        }
    }

    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(NetworkError)
        case offline
    }

    @Published private(set) var sections: [Section] = []
    @Published private(set) var state: LoadState = .idle

    private let service: ITunesServiceType
    private let reachability: Reachability
    private let favorites: FavoritesStoreType
    private let term: String

    init(
        service: ITunesServiceType = ITunesService(),
        reachability: Reachability = .shared,
        favorites: FavoritesStoreType = FavoritesStore(),
        term: String = "周杰倫"
    ) {
        self.service = service
        self.reachability = reachability
        self.favorites = favorites
        self.term = term
    }

    var searchTerm: String {
        term
    }

    func load() async {
        guard reachability.isReachable else {
            state = .offline
            return
        }
        state = .loading
        do {
            async let songsResponse = service.fetchSongs(term: term, limit: 36, offset: 0)
            async let albumsResponse = service.fetchAlbums(term: term, limit: 36, offset: 0)
            let (songs, albums) = try await (songsResponse, albumsResponse)
            sections = [
                .songs(songs.results),
                .albums(albums.results)
            ]
            state = .loaded
        } catch let networkError as NetworkError {
            state = .failed(networkError)
        } catch {
            state = .failed(.underlying(error))
        }
    }

    func numberOfSections() -> Int {
        sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard sections.indices.contains(section) else { return 0 }
        return sections[section].count
    }

    func item(at indexPath: IndexPath) -> Any? {
        guard sections.indices.contains(indexPath.section) else { return nil }
        switch sections[indexPath.section] {
        case .songs(let songs):
            return songs[indexPath.row]
        case .albums(let albums):
            return albums[indexPath.row]
        }
    }

    func title(for section: Int) -> String? {
        guard sections.indices.contains(section) else { return nil }
        return sections[section].title
    }

    func toggleFavoriteSong(for songId: Int) {
        favorites.toggle(id: "\(songId)")
    }

    func toggleFavoriteAlbum(for albumId: Int) {
        favorites.toggle(id: "album_\(albumId)")
    }

    func isFavoriteSong(id: Int) -> Bool {
        favorites.isFavorite(id: "\(id)")
    }

    func isFavoriteAlbum(id: Int) -> Bool {
        favorites.isFavorite(id: "album_\(id)")
    }
}
