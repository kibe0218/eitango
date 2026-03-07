import SwiftUI
import CoreData
import Combine

class FlipAction {
    
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
        flippedCard: Card_ST,
    ) {
        uiState.screenSlots[slotIndex].isFlipped = true
        Task {
            do { try await DelayController.wait(seconds: waitTime) } catch {return}
            let nextcard = engine.nextCard(state: state, flippedCard: flippedCard)
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
    func mistakeTask(i: Int) {
        if let card = uiState.screenSlots[i].card {
            state.mistakeCards.append(card)
        }
        state.finish = false
    }
    
}
