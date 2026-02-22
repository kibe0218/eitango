import Foundation
import Combine

class ListViewModel: ObservableObject {
    
    private let listRepository: ListRepositoryProtocol
    
    init(listRepository: ListRepositoryProtocol) {
        self.listRepository = listRepository
    }
    
    func add(list: AddListRequest) async throws -> List_ST {
        return try await listRepository.add(list: list)
    }
    
    func delete(id: String) async throws {
        try await listRepository.delete(id: id)
    }
    
    func reload() async throws -> [List_ST]{
        return try await listRepository.reload()
    }
}
