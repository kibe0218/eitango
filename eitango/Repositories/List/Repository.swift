import Foundation
import Combine
import SwiftUI

protocol ListRepositoryProtocol {
    func fetchAll() async throws -> [CardList]
    func reload(userId: String) async throws-> [CardList]
    func add(userId: String, list: AddListRequest) async throws -> CardList
    func delete(userId: String, id: String) async throws
}

class ListRepository: ListRepositoryProtocol {
        
    let dbRepository: List_DataBaseRepositoryProtocol
    let cdRepository: List_CoreDataRepositoryProtocol
    init (
        list_dbRepository: List_DataBaseRepositoryProtocol,
        list_cdRepository: List_CoreDataRepositoryProtocol,
    ) {
        self.dbRepository = list_dbRepository
        self.cdRepository = list_cdRepository
    }
    
    // MARK: - Public CRUD Functions
    
    // CoreDataから全て読み込み
    func fetchAll() throws -> [CardList] {
        return try cdRepository.fetchAll()
    }
    
    // DB基準で再読み込み
    func reload(userId: String) async throws -> [CardList] {
        try cdRepository.saveAll(lists: try await dbRepository.fetchAll(userId: userId))
        return try cdRepository.fetchAll()
    }

    // 追加
    func add(userId: String, list: AddListRequest) async throws -> CardList {
        let list = try await dbRepository.add(userId: userId, list: list)
        guard !list.id.isEmpty else { throw AuthError.unknown }
        _ = try cdRepository.add(list: list)
        return list
    }

    // 削除
    func delete(userId: String, id: String) async throws {
        try await dbRepository.delete(userId: userId, id: id)
        try cdRepository.delete(id: id)
    }
}
