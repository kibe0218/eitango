import Foundation

struct AddCardRequest: Encodable {
    let en: String
    let jp: String
}

struct UpdateCardRequest: Encodable {
    let id: String
    let en: String
    let jp: String
}
