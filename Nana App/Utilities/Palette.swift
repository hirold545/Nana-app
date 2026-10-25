import UIKit

/// Flat Material-style palette.
enum Palette {
    static let tile: [UIColor] = [0x5CB8FF, 0xFFC93C, 0x4CC38A, 0xFF6FA5, 0x8E7CFF, 0xFF9B54].map { UIColor(hex: $0) }
    static let tileNames = ["Sky", "Sun", "Leaf", "Berry", "Grape", "Orange"]
    static let ink = UIColor(hex: 0x1E1633)
    static let primary = UIColor(hex: 0x6750A4)
    static let danger = UIColor(hex: 0xB3261E)
    static let bg = UIColor.dynamic(0xFEF7FF, 0x141218)
    static let text = UIColor.dynamic(0x1D1B20, 0xE6E0E9)
    static let muted = UIColor.dynamic(0x49454F, 0xCAC4D0)
    static let surface = UIColor.dynamic(0xF3EDF7, 0x211F26)
    static let outline = UIColor.dynamic(0x79747E, 0x938F99)
}
