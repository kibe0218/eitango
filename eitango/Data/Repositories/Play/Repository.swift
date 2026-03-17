import Foundation
import Combine
import SwiftUI

protocol PlayRepositoryProtocol {
    func fetch() throws -> PlaySession
    func save(play: PlaySession) throws
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
    func fetch() throws -> PlaySession {
        return try cdRepository.fetch()
    }

    // CoreDataに全て保存
    func save(play: PlaySession) throws {
        return try cdRepository.save(play: play)
    }
}
