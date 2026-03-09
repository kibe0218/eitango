import SwiftUI
import CoreData

protocol Setting_CoreDataRepositoryProtocol {
    func fetch() throws -> Setting
    func save(setting: Setting) throws
}

class Setting_CoreDataRepository: Setting_CoreDataRepositoryProtocol {
    
    //コアデータ読み込みStructを読み込み
    private func currentEntity() throws -> SettingEntity? {
        let request = CoreDataRequest()
        return try request.fetchSingle(ofType: SettingEntity.self)
    }
    
    //Structに変換
    private func convertEntitiesToStructs(entity: SettingEntity) throws -> Setting {
        let colorTheme = ColorTheme(rawValue: Int(entity.colorTheme)) ?? .normal
        let repeatFlag = entity.repeatFlag
        let shuffleFlag = entity.shuffleFlag
        let selectedListId = entity.selectedListId
        let waitTime = entity.waitTime
        return Setting (
            colorTheme: colorTheme,
            repeatFlag: repeatFlag,
            shuffleFlag: shuffleFlag,
            selectedListId: selectedListId,
            waitTime: Int(waitTime)
        )
    }
    
    //Entityに変換
    private func convertStructsToEntities(setting: Setting) throws {
            let entity = SettingEntity(context: context)
            entity.colorTheme = Int16(setting.colorTheme.rawValue)
            entity.repeatFlag = setting.repeatFlag
            entity.shuffleFlag = setting.shuffleFlag
            entity.selectedListId = setting.selectedListId
            entity.waitTime = Int16(setting.waitTime)
    }
    
    //デフォルト値
    let defaultSetting = Setting(
        colorTheme: .normal,
        repeatFlag: false,
        shuffleFlag: false,
        selectedListId: nil,
        waitTime: 2
    )
    
    //同期
    func fetch() throws -> Setting {
        guard let entity = try currentEntity() else { return defaultSetting }
        return try convertEntitiesToStructs(entity: entity)
    }
    
    //変更保存
    func save(setting: Setting) throws {
        do {
            if let oldsetting = try currentEntity() {
                context.delete(oldsetting)
            }
            try convertStructsToEntities(setting: setting)
            try context.save()
        } catch {
            print("saveSettingsError: \(error.localizedDescription)")
        }
    }
}
