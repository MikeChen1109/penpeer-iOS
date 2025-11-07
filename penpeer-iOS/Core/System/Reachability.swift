import Combine
import Network

final class Reachability {
    static let shared = Reachability()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "net.penpeer.reachability")
    @Published private(set) var isReachable: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isReachable = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
