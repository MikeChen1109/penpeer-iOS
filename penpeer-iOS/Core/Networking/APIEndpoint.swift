import Foundation

enum APIEndpoint {
    case search(term: String, media: String? = nil, entity: String? = nil, limit: Int? = nil)

    var baseURL: String { "https://itunes.apple.com" }

    var path: String {
        switch self {
        case .search:
            return "/search"
        }
    }

    var method: String { "GET" }

    var parameters: [String: Any] {
        switch self {
        case let .search(term, media, entity, limit):
            var params: [String: Any] = ["term": term]
            if let media { params["media"] = media }
            if let entity { params["entity"] = entity }
            if let limit { params["limit"] = limit }
            return params
        }
    }
}
