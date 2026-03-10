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
        engine: SessionEngine = SessionEngine(),
        listSession: ListSession,
        uiRepository: PlayRepositoryProtocol,
    ) {
        self.cardSession = cardSession
        self.uiState = uiState
        self.engine = engine
        self.listSession = listSession
        self.uiRepository = uiRepository
    }

    func updateView() async throws {
        uiState.reset()
        guard listSession.lists.contains(where: {
            $0.id == uiState.play.selectedListId
        }) else {
            uiState.play.selectedListId = listSession.lists.first?.id
            print("🟡 selectedListId無効だったので初期化:")
        }
        try uiRepository.save(play: uiState.play)
    }
    
    // カードを翻す
    @MainActor
    func flipTask(
        slotIndex: Int,
        waitTime: Int,
        flippedCard: Card,
    ) {
        uiState.play.screenSlots[slotIndex].isFlipped = true
        Task {
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
    func mistakeTask(mistakeCard: Card) {
        var card = mistakeCard
        card.order = uiState.play.mistakeCards.count
        uiState.play.mistakeCards.append(card)
        uiState.play.finish = false
    }
}
