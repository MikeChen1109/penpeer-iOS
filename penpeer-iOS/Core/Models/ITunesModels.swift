import Foundation

struct SearchResponse<T: Decodable>: Decodable {
    let resultCount: Int
    let results: [T]
}

struct Song: Decodable, Identifiable, Hashable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let artworkUrl100: String?
    let trackPrice: Double?
    let collectionName: String?
    let primaryGenreName: String?
    let previewUrl: String?

    var id: Int { trackId }
}

struct Album: Decodable, Identifiable, Hashable {
    let collectionId: Int
    let collectionName: String
    let artistName: String
    let artworkUrl100: String?
    let collectionPrice: Double?
    let trackCount: Int?

    var id: Int { collectionId }
}

struct MusicVideo: Decodable, Identifiable, Hashable {
    let trackId: Int
    let trackName: String
    let artistName: String
    let artworkUrl100: String?
    let trackPrice: Double?
    let primaryGenreName: String?
    let previewUrl: String?

    var id: Int { trackId }
}
