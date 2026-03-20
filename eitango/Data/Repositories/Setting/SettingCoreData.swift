import SwiftUI
import CoreData

protocol Setting_CoreDataRepositoryProtocol {
    func fetch() throws -> Setting
    func save(setting: Setting) throws
}

class Setting_CoreDataRepository: Setting_CoreDataRepositoryProtocol {
    
    // MARK: - Private Helpers
    
    // コアデータ読み込みStructを読み込み
    private func currentEntity() throws -> SettingEntity? {
        let request = CoreDataRequest()
        return try request.fetchSingle(ofType: SettingEntity.self)
    }
    
    // Structに変換
    private func convertEntitiesToStructs(entity: SettingEntity) throws -> Setting {
        let colorTheme = ColorTheme(rawValue: Int(entity.colorTheme)) ?? .normal
        let waitTime = entity.waitTime
        return Setting (
            colorTheme: colorTheme,
            waitTime: Int(waitTime)
        )
    }
    
    // Entityに変換
    private func convertStructsToEntities(setting: Setting) throws {
            let entity = SettingEntity(context: context)
            entity.colorTheme = Int16(setting.colorTheme.rawValue)
            entity.waitTime = Int16(setting.waitTime)
    }
    
    // MARK: - Public CRUD Functions
    
    // 同期
    func fetch() throws -> Setting {
        guard let entity = try currentEntity() else { return Setting() }
        return try convertEntitiesToStructs(entity: entity)
    }
    
    // 変更保存
    func save(setting: Setting) throws {
        do {
            if let oldsetting = try currentEntity() {
                context.delete(oldsetting)
            }
            try convertStructsToEntities(setting: setting)
            try context.save()
        } catch {
            context.rollback()
            print("saveSettingsError: \(error.localizedDescription)")
        }
    }
}
