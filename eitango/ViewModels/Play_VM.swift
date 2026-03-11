import SwiftUI
import CoreData
import Combine

class PlayViewModel {
    
    private let cardSession: CardSession
    private let uiState: PlayUIState
    private let engine: SessionEngine
    private let listSession: ListSession
    private let uiRepository: PlayRepositoryProtocol
    init(
        cardSession: CardSession,
        uiState: PlayUIState,
        listSession: ListSession,
        uiRepository: PlayRepositoryProtocol,
        engine: SessionEngine = SessionEngine()
    ) {
        self.cardSession = cardSession
        self.uiState = uiState
        self.engine = engine
        self.listSession = listSession
        self.uiRepository = uiRepository
    }

    func updateView() async throws {
        uiState.reset()
        try uiRepository.save(play: uiState.play)
    }
    
    // カードを反転
    @MainActor
    func flipTask(
        slotIndex: Int,
        waitTime: Int,
        flippedCard: Card,
    ) {
        uiState.play.screenSlots[slotIndex].isFlipped = true
        Task { @MainActor in
            do { try await DelayController.wait(seconds: Double(waitTime))} catch {return}
            let nextcard = engine.nextCard(
                cards: cardSession.cards,
                mistakeCards: uiState.play.mistakeCards,
                looping: uiState.play.looping,
                mode: uiState.play.mode,
                flippedCard: flippedCard)
            if let nextcard {
                if let first = uiState.play.mistakeCards.first, first.id == nextcard.id {
                    uiState.play.mistakeCards.removeFirst()
                }
                uiState.play.screenSlots[slotIndex].card = nextcard
                uiState.play.screenSlots[slotIndex].isFlipped = false
            } else {
                uiState.play.screenSlots[slotIndex].isFinished = true
                if uiState.play.screenSlots.allSatisfy({ $0.isFinished }) {
                    uiState.play.finish = true
                }
            }
        }
    }
        
    // ミスったカードを追加
    @MainActor
    func mistakeTask(mistakeCard: Card) async throws {
        var card = mistakeCard
        card.order = uiState.play.mistakeCards.count
        uiState.play.mistakeCards.append(card)
        uiState.play.finish = false
        withAnimation {
            uiState.play.showNotification = true
        }
        try await DelayController.wait(seconds: 2)
        self.uiState.play.showNotification = false
    }
}
