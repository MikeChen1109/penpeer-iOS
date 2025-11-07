import Foundation

protocol ITunesServiceType {
    func fetchSongs(term: String, limit: Int, offset: Int) async throws -> SearchResponse<Song>
    func fetchAlbums(term: String, limit: Int, offset: Int) async throws -> SearchResponse<Album>
}

final class ITunesService: ITunesServiceType {
    private let client: NetworkClientType

    init(client: NetworkClientType = NetworkClient()) {
        self.client = client
    }

    func fetchSongs(term: String, limit: Int, offset: Int) async throws -> SearchResponse<Song> {
        try await client.request(.search(term: term, media: "music", limit: limit, offset: offset))
    }

    func fetchAlbums(term: String, limit: Int, offset: Int) async throws -> SearchResponse<Album> {
        try await client.request(.search(term: term, entity: "album", limit: limit, offset: offset))
    }
}
