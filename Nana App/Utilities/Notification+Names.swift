import UIKit

/// Names of the "announcements" screens listen for: one when tiles change and one when audio
/// changes.
extension Notification.Name {
    static let tilesChanged = Notification.Name("tilesChanged")
    static let audioStateChanged = Notification.Name("audioStateChanged")
}
