import Foundation

protocol FavoritesStoreType {
    func isFavorite(id: String) -> Bool
    func toggle(id: String)
    func all() -> Set<String>
}

final class FavoritesStore: FavoritesStoreType {
    static let shared = FavoritesStore()
    
    private let key = "favorites.ids"
    private let defaults: UserDefaults
    private var cache: Set<String>

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.cache = Set(defaults.stringArray(forKey: key) ?? [])
    }

    func isFavorite(id: String) -> Bool {
        cache.contains(id)
    }

    func toggle(id: String) {
        if cache.contains(id) {
            cache.remove(id)
        } else {
            cache.insert(id)
        }
        defaults.set(Array(cache), forKey: key)
    }

    func all() -> Set<String> {
        cache
    }
}
