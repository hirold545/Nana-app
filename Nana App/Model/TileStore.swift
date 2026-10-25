import UIKit

/// Saves tiles, recordings and photos on this device only.
final class TileStore {
    static let shared = TileStore()

    private(set) var tiles: [Tile] = []

    private let fm = FileManager.default
    private let root: URL
    private let cache = NSCache<NSString, UIImage>()

    /// Runs once. Finds the app Documents folder, creates the sounds and photos folders, and loads
    /// the saved tiles.
    private init() {
        root = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for dir in ["sounds", "photos"] {
            try? fm.createDirectory(at: root.appendingPathComponent(dir), withIntermediateDirectories: true)
        }
        load()
    }

    private var indexURL: URL { root.appendingPathComponent("tiles.json") }
    /// Where the voice recording for a tile id is stored.
    func audioURL(_ id: String) -> URL { root.appendingPathComponent("sounds/\(id).m4a") }
    /// Where a tile photo file is stored.
    private func photoURL(_ file: String) -> URL { root.appendingPathComponent("photos/\(file)") }

    /// Loads a tile photo and remembers it in memory so scrolling stays fast. Returns nil if the
    /// tile has no photo.
    func image(_ file: String?) -> UIImage? {
        guard let file else { return nil }
        if let hit = cache.object(forKey: file as NSString) { return hit }
        guard let img = UIImage(contentsOfFile: photoURL(file).path) else { return nil }
        cache.setObject(img, forKey: file as NSString)
        return img
    }

    /// Reads the saved tiles from disk. On the very first launch it creates the four starter tiles
    /// (Mama, Dada, Pet, Giggle).
    private func load() {
        if let data = try? Data(contentsOf: indexURL),
           let saved = try? JSONDecoder().decode([Tile].self, from: data) {
            tiles = saved
            return
        }
        let defaults = [("Mama", "👩"), ("Dada", "👨"), ("Pet", "🐶"), ("Giggle", "😄")]
        tiles = defaults.enumerated().map { i, d in
            Tile(id: "t\(i)", name: d.0, words: d.1, colorIndex: i, hasAudio: false, photoFile: nil)
        }
        persist()
    }

    /// Writes all tiles to disk as JSON and tells the screens to refresh.
    private func persist() {
        if let data = try? JSONEncoder().encode(tiles) {
            try? data.write(to: indexURL, options: .atomic)
        }
        NotificationCenter.default.post(name: .tilesChanged, object: nil)
    }

    /// Makes a blank tile (not saved yet) using the next color in the list.
    func newTile() -> Tile {
        Tile(id: UUID().uuidString, name: "", words: "", colorIndex: tiles.count % Tile.colorCount,
             hasAudio: false, photoFile: nil)
    }

    /// Saves a tile. Moves a new recording into place, replaces or removes the photo if it changed,
    /// then adds or updates the tile and saves everything.
    func commit(_ tile: Tile, newAudio: URL?, newPhoto: UIImage?, photoRemoved: Bool) {
        var t = tile
        if let temp = newAudio {
            let dest = audioURL(t.id)
            try? fm.removeItem(at: dest)
            try? fm.moveItem(at: temp, to: dest)
            t.hasAudio = true
        }
        if newPhoto != nil || photoRemoved {
            if let old = t.photoFile {
                try? fm.removeItem(at: photoURL(old))
                cache.removeObject(forKey: old as NSString)
            }
            t.photoFile = nil
            if let img = newPhoto, let data = img.jpegData(compressionQuality: 0.8) {
                let name = "\(t.id)_\(Int(Date().timeIntervalSince1970)).jpg"
                try? data.write(to: photoURL(name))
                t.photoFile = name
            }
        }
        if let i = tiles.firstIndex(where: { $0.id == t.id }) {
            tiles[i] = t
        } else {
            tiles.append(t)
        }
        persist()
    }

    /// Deletes a tile together with its voice file and photo.
    func delete(_ tile: Tile) {
        try? fm.removeItem(at: audioURL(tile.id))
        if let p = tile.photoFile { try? fm.removeItem(at: photoURL(p)) }
        tiles.removeAll { $0.id == tile.id }
        persist()
    }
}
