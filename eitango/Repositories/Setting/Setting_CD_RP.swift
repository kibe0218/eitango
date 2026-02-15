import SwiftUI
import CoreData

protocol SettingRepositoryProtocol {
    func fetch() throws -> Setting_ST?
    func save(setting: Setting_ST) throws
}

class SettingRepository: SettingRepositoryProtocol {
    
    //コアデータ読み込みStructを読み込み
    private func currentEntity() throws -> SettingEntity? {
        let request = CoreDataRequest()
        return try request.fetchOne(ofType: SettingEntity.self)
    }
    
    //チェックと変換作業
    private func checkConvertEntity(entity: SettingEntity) throws -> Setting_ST {
        let colortheme = entity.colortheme
        let repeatFlag = entity.repeatFlag
        let shuffleFlag = entity.shuffleFlag
        let selectedListId = entity.selectedListId
        let waitTime = entity.waittime
        return Setting_ST (
            colortheme: Int(colortheme),
            repeatFlag: repeatFlag,
            shuffleFlag: shuffleFlag,
            selectedListId: selectedListId,
            waitTime: Int(waitTime)
        )
    }
    
    //デフォルト値
    let defaultSetting = Setting_ST(
        colortheme: 1,
        repeatFlag: false,
        shuffleFlag: false,
        selectedListId: nil,
        waitTime: 2
    )
    
    //同期
    func fetch() throws -> Setting_ST? {
        guard let entity = try currentEntity() else { return nil }
        return try checkConvertEntity(entity: entity)
    }
    
    //変更保存
    func save(setting: Setting_ST) throws {
        do {
            if let oldsetting = try currentEntity() {
                context.delete(oldsetting)
            }
            let entity = SettingEntity(context: context)
            entity.colortheme = Int16(setting.colortheme)
            entity.repeatFlag = setting.repeatFlag
            entity.shuffleFlag = setting.shuffleFlag
            entity.selectedListId = setting.selectedListId
            entity.waitTime = Int16(setting.waitTime)
            try context.save()
        } catch {
            print("saveSettingsError: \(error.localizedDescription)")
        }
    }
}
