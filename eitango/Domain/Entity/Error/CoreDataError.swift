import Foundation

// CoreData
enum CoreDataError: Error {
    case inconsistentUserData
    case inconsistentListData
    case inconsistentCardData
    case saveFailed
    case deleteFailed
}
