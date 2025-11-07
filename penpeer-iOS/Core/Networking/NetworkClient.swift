import Alamofire
import Foundation

protocol NetworkClientType {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class NetworkClient: NetworkClientType {
    private let session: Session
    private let reachability: Reachability

    init(session: Session = .default, reachability: Reachability = .shared) {
        self.session = session
        self.reachability = reachability
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard reachability.isReachable else { throw NetworkError.offline }

        let urlString = endpoint.baseURL + endpoint.path
        return try await withCheckedThrowingContinuation { continuation in
            session.request(urlString, method: .get, parameters: endpoint.parameters)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        let mapped = Self.mapError(error, statusCode: response.response?.statusCode)
                        continuation.resume(throwing: mapped)
                    }
                }
        }
    }

    private static func mapError(_ error: AFError, statusCode: Int?) -> NetworkError {
        if let urlError = error.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .offline
            case .timedOut:
                return .timeout
            case .cancelled:
                return .cancelled
            default:
                break
            }
        }
        if error.isResponseSerializationError { return .decoding }
        if let status = statusCode { return .server(status: status) }
        return .underlying(error)
    }
}
