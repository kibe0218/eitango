import SwiftUI
import CoreData
import Combine

class PlayViewModel {
    
    @Published var playSession: PlaySession
    @Published var playUI: PlayUI
    
    private let cardSession: CardSession
    private let listSession: ListSession
    private let settingSession: SettingSession
    private let colorState: ColorUIState
    private let engine: SessionEngine
    private let uiRepository: PlayRepositoryProtocol
    init(
        cardSession: CardSession,
        listSession: ListSession,
        settingSession: SettingSession,
        colorState: ColorUIState,
        engine: SessionEngine = SessionEngine(),
        uiRepository: PlayRepositoryProtocol
    ) {
        self.cardSession = cardSession
        self.listSession = listSession
        self.settingSession = settingSession
        self.engine = engine
        self.uiRepository = uiRepository
    }

    // UIをリセット、保存すべきものは保存
    func updateView() async {
        playUI = PlayUI()
        playUI.screenSlots = engine.firstCard(cards: cardSession.cards, mode: playSession.mode)
        for slot in playUI.screenSlots.compactMap({ $0 }) {
            playSession.shownCount += 1
        }
        do {
            try uiRepository.save(play: playSession)
        } catch {
            
        }
        
    }
    
    // カードを反転
    @MainActor
    func flipTask(
        slotIndex: Int,
    ) {
        guard var slot = playUI.screenSlots[slotIndex] else { return }
        slot.cardSide = .back
        playUI.screenSlots[slotIndex] = slot
        let nextCard = engine.nextCard(
            cards: cardSession.cards,
            looping: playSession.looping,
            mode: playSession.mode,
            shownCount: playSession.shownCount,
            mistakeCards: &playSession.mistakeCards
        )
        Task { @MainActor in
            do {
                try await DelayController.wait(seconds: Double(settingSession.setting.waitTime))
            } catch {return}
            if let nextcard = nextCard {
                playSession.shownCount += 1
                slot.card = nextcard
                slot.cardSide = .front
                playUI.screenSlots[slotIndex] = slot
            } else {
                playUI.screenSlots[slotIndex] = nil
            }
        }
    }
        
    // ミスったカードを追加
    @MainActor
    func mistakeTask(slotIndex: Int) async throws {
        guard var slot = playUI.screenSlots[slotIndex] else { return }
        if let index = cardSession.cards.firstIndex(where: { $0.id == slot.card.id }) {
            cardSession.cards[index].mistake = true
        }
        playSession.mistakeCards.append(slot.card.id)
        withAnimation {
            playUI.showNotification = true
        }
        try await DelayController.wait(seconds: 2)
        playUI.showNotification = false
    }
    
    // カードの色を返す
    func currentCardColor(position: Int, colorScheme: ColorScheme) -> Color {
        guard let slot = playUI.screenSlots[position] else { return .clear }
        return cardColor(
            side: slot.cardSide,
            reverse: playSession.reverse,
            colorTheme: colorState.currentTheme,
            colorScheme: colorScheme
        )
    }
}
