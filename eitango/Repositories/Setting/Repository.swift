import Foundation
import Combine
import SwiftUI

protocol SettingRepositoryProtocol {
    func fetch() throws -> Setting
    func save(setting: Setting) throws
}

class SettingRepository: SettingRepositoryProtocol {
    
    let cdRepository: Setting_CoreDataRepositoryProtocol
    init (
        Setting_cdRepository: Setting_CoreDataRepositoryProtocol,
    ) throws {
        self.cdRepository = Setting_cdRepository
    }
    
    // MARK: - Public CRUD Functions
    
    // CoreDataから全て読み込み
    func fetch() throws -> Setting {
        return try cdRepository.fetch()
    }

    // CoreDataに全て保存
    func save(setting: Setting) throws {
        return try cdRepository.save(setting: setting)
    }
}
