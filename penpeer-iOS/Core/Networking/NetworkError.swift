import Foundation

enum NetworkError: Error, LocalizedError {
    case offline
    case timeout
    case server(status: Int)
    case decoding
    case cancelled
    case underlying(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .offline:
            return "目前離線，請檢查網路連線。"
        case .timeout:
            return "連線逾時，請稍後重試。"
        case .server(let status):
            return "伺服器錯誤（\(status)）。"
        case .decoding:
            return "資料格式有誤。"
        case .cancelled:
            return "已取消。"
        case .underlying(let error):
            return error.localizedDescription
        case .unknown:
            return "發生未知錯誤。"
        }
    }
}
