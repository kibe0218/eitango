import Foundation

extension Character {
    var isEmoji: Bool {
        unicodeScalars.first?.properties.isEmojiPresentation == true
        || unicodeScalars.first?.properties.isEmoji == true
    }
}
