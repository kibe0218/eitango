import Foundation

struct Setting: Codable {
    let colorTheme: ColorTheme
    let repeatFlag: Bool
    let shuffleFlag: Bool
    let selectedListId: String?
    let waitTime: Int
}
