import SwiftUI
import CoreData

protocol Play_CoreDataRepositoryProtocol {
    func fetch() throws -> Play
    func save(play: Play) throws
}

class Play_CoreDataRepository: Play_CoreDataRepositoryProtocol {
    
    // MARK: - Private Helpers
    
    // コアデータ読み込みStructを読み込み
    private func currentEntity() throws -> PlayEntity? {
        let request = CoreDataRequest()
        return try request.fetchSingle(ofType: PlayEntity.self)
    }
    
    // Structに変換
    private func convertEntitiesToStructs(entity: PlayEntity) throws -> Play {
        let mode = PlayMode(rawValue: Int(entity.mode)) ?? .ordered
        let looping = entity.looping
        let reverse = entity.reverse
        let selectedListId = entity.selectedListId
        return Play (
            mode: mode,
            looping: looping,
            reverse: reverse,
            selectedListId: selectedListId
        )
    }
    
    // Entityに変換
    private func convertStructsToEntities(play: Play) throws {
            let entity = PlayEntity(context: context)
            entity.mode = Int16(play.mode.rawValue)
            entity.looping = play.looping
            entity.reverse = play.reverse
            entity.selectedListId = play.selectedListId
    }
    
    // MARK: - Public CRUD Functions

    // 同期
    func fetch() throws -> Play {
        guard let entity = try currentEntity() else { return Play() }
        return try convertEntitiesToStructs(entity: entity)
    }
    
    // 変更保存
    func save(play: Play) throws {
        do {
            if let oldPlay = try currentEntity() {
                context.delete(oldPlay)
            }
            try convertStructsToEntities(play: play)
            try context.save()
        } catch {
            context.rollback()
            print("savePlayError: \(error.localizedDescription)")
        }
    }
}
