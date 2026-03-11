import Foundation
import Combine
import SwiftUI

protocol PlayRepositoryProtocol {
    func fetch() throws -> Play
    func save(play: Play) throws
}

class PlayRepository: PlayRepositoryProtocol {
    
    let cdRepository: Play_CoreDataRepositoryProtocol
    init (
        Play_cdRepository: Play_CoreDataRepositoryProtocol,
    ) {
        self.cdRepository = Play_cdRepository
    }
    
    // MARK: - Public CRUD Functions

    // CoreDataから全て読み込み
    func fetch() throws -> Play {
        return try cdRepository.fetch()
    }

    // CoreDataに全て保存
    func save(play: Play) throws {
        return try cdRepository.save(play: play)
    }
}
