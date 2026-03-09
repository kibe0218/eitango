import SwiftUI
import CoreData
import Combine

class ActionViewModel {
    
    private let cardSession: CardSession
    private let uiState: PlayUIState
    private let engine: SessionEngine
    init(
        cardSession: CardSession,
        uiState: PlayUIState,
        engine: SessionEngine = SessionEngine()
    ) {
        self.cardSession = cardSession
        self.uiState = uiState
        self.engine = engine
    }
    
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
