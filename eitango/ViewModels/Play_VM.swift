import SwiftUI
import CoreData
import Combine

class ActionViewModel {
    
    private let state: SessionState
    private let uiState: FourCardUIState
    private let engine: SessionEngine
    init(
        state: SessionState,
        uiState: FourCardUIState,
        engine: SessionEngine = SessionEngine()
    ) {
        self.state = state
        self.uiState = uiState
        self.engine = engine
    }
    
    @MainActor
    func flipTask(
        slotIndex: Int,
        waitTime: Int,
        flippedCard: Card,
    ) {
        uiState.screenSlots[slotIndex].isFlipped = true
        Task {
            do { try await DelayController.wait(seconds: Double(waitTime))} catch {return}
            let nextcard = engine.nextCard(
                cards: state.cards,
                mistakeCards: state.mistakeCards,
                looping: state.looping,
                mode: state.mode,
                flippedCard: flippedCard)
            if let nextcard {
                if let first = state.mistakeCards.first, first.id == nextcard.id {
                    state.mistakeCards.removeFirst()
                }
                uiState.screenSlots[slotIndex].card = nextcard
                uiState.screenSlots[slotIndex].isFlipped = false
            } else {
                uiState.screenSlots[slotIndex].isFinished = true
                if uiState.screenSlots.allSatisfy({ $0.isFinished }) {
                    state.finish = true
                }
            }
        }
    }
        
    //ミスったカードを追加
    func mistakeTask(mistakeCard: Card) {
        var card = mistakeCard
        card.order = state.mistakeCards.count
        state.mistakeCards.append(card)
        state.finish = false
    }
}
