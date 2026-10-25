import UIKit

/// One soundboard tile: its name, words, color, whether it has a recorded voice, and its photo file
/// name (if any).
struct Tile: Codable, Equatable {
    var id: String
    var name: String
    var words: String
    var colorIndex: Int
    var hasAudio: Bool
    var photoFile: String?

    /// How many tile colors exist (matches Palette.tile in the Views layer). Used to cycle colors.
    static let colorCount = 6
}
