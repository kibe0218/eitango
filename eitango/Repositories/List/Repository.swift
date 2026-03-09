import Foundation
import Combine
import SwiftUI

protocol ListRepositoryProtocol {
    func fetchAll() async throws -> [List]
    func reload() async throws-> [List]
    func add(list: AddListRequest) async throws -> List
    func delete(id: String) async throws
}

class ListRepository: ListRepositoryProtocol {
        
    let dbRepository: List_DataBaseRepositoryProtocol
    let cdRepository: List_CoreDataRepositoryProtocol
    init (
        list_dbRepository: List_DataBaseRepositoryProtocol,
        list_cdRepository: List_CoreDataRepositoryProtocol,
    ) throws {
        self.dbRepository = list_dbRepository
        self.cdRepository = list_cdRepository
    }
    
    // MARK: - Public CRUD Functions
    
    // CoreDataから全て読み込み
    func fetchAll() throws -> [List] {
        return try cdRepository.fetchAll()
    }
    
    // DB基準で再読み込み
    func reload() async throws -> [List] {
        try cdRepository.saveAll(lists: try await dbRepository.fetch())
        return try cdRepository.fetchAll()
    }

    // 追加
    func add(list: AddListRequest) async throws -> List {
        let list = try await dbRepository.add(list: list)
        guard !list.id.isEmpty else { throw AuthError.unknown }
        _ = try cdRepository.add(list: list)
        return list
    }

    // 削除
    func delete(id: String) async throws {
        try await dbRepository.delete(id: id)
        try cdRepository.delete(id: id)
    }
}
