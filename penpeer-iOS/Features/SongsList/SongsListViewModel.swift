import Combine
import Foundation

@MainActor
final class SongsListViewModel: ObservableObject {
    @Published private(set) var items: [Song] = []
    @Published var isLoading: Bool = false
    @Published var error: NetworkError?

    private let service: ITunesServiceType
    private let favorites: FavoritesStoreType
    private let term: String
    private let pageSize: Int

    init(
        term: String,
        service: ITunesServiceType = ITunesService(),
        favorites: FavoritesStoreType = FavoritesStore.shared,
        pageSize: Int = 36
    ) {
        self.term = term
        self.service = service
        self.favorites = favorites
        self.pageSize = pageSize
    }

    func loadFirstPage() async {
        reset()
        await fetchSongs()
    }

    func toggleFavorite(_ song: Song) {
        favorites.toggle(id: "\(song.trackId)")
        objectWillChange.send()
    }

    func isFavorite(_ song: Song) -> Bool {
        favorites.isFavorite(id: "\(song.trackId)")
    }

    private func fetchSongs() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await service.fetchSongs(term: term, limit: pageSize, offset: 0)
            items = response.results
            error = nil
        } catch let networkError as NetworkError {
            error = networkError
        } catch let e {
            error = .underlying(e)
        }
    }

    private func reset() {
        items = []
        error = nil
    }
}
