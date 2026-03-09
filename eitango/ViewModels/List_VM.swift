import Foundation
import Combine

class ListViewModel: ObservableObject {
    
    private let listRepository: ListRepositoryProtocol
    
    init(listRepository: ListRepositoryProtocol) {
        self.listRepository = listRepository
    }
    
    func fetchAll() async throws -> [List] {
        return try await listRepository.fetchAll()
    }
    
    func reload() async throws -> [List] {
        return try await listRepository.reload()
    }
    
    func add(list: AddListRequest) async throws -> List {
        return try await listRepository.add(list: list)
    }
    
    func delete(id: String) async throws {
        try await listRepository.delete(id: id)
    }
}
