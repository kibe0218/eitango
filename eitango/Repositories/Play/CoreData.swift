import SwiftUI
import CoreData

protocol Play_CoreDataRepositoryProtocol {
    func fetch() throws -> PlaySession
    func save(play: PlaySession) throws
}

class Play_CoreDataRepository: Play_CoreDataRepositoryProtocol {
    
    // MARK: - Private Helpers
    
    // コアデータ読み込みStructを読み込み
    private func currentEntity() throws -> PlayEntity? {
        let request = CoreDataRequest()
        return try request.fetchSingle(ofType: PlayEntity.self)
    }
    
    // Structに変換
    private func convertEntitiesToStructs(entity: PlayEntity) throws -> PlaySession {
        var shownCount = Int(entity.shownCount)
        let mode = PlayMode(rawValue: Int(entity.mode)) ?? .ordered
        let looping = entity.looping
        let reverse = entity.reverse
        let selectedListId = entity.selectedListId
        return PlaySession (
            shownCount: shownCount,
            mode: mode,
            looping: looping,
            reverse: reverse,
            selectedListId: selectedListId
        )
    }
    
    // Entityに変換
    private func convertStructsToEntities(play: PlaySession) throws {
            let entity = PlayEntity(context: context)
            entity.shownCount = Int16(play.shownCount)
            entity.mode = Int16(play.mode.rawValue)
            entity.looping = play.looping
            entity.reverse = play.reverse
            entity.selectedListId = play.selectedListId
    }
    
    // MARK: - Public CRUD Functions

    // 同期
    func fetch() throws -> PlaySession {
        guard let entity = try currentEntity() else { return PlaySession() }
        return try convertEntitiesToStructs(entity: entity)
    }
    
    // 変更保存
    func save(play: PlaySession) throws {
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
