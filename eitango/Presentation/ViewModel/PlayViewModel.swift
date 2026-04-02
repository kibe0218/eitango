import SwiftUI
import CoreData
import Combine

class PlayViewModel: ObservableObject {
    
    @Published var playSession: PlaySession
    @Published var playUI: PlayUI
    
    private let cardSession: CardSession
    private let listSession: ListSession
    private let settingSession: SettingSession
    private let colorState: ColorUIState
    private let logic: CardNavigation
    private let uiRepository: PlayRepositoryProtocol
    init(
        playSession: PlaySession,
        playUI: PlayUI = PlayUI(),
        cardSession: CardSession,
        listSession: ListSession,
        settingSession: SettingSession,
        colorState: ColorUIState,
        logic: CardNavigation = CardNavigation(),
        uiRepository: PlayRepositoryProtocol
    ) {
        self.playSession = playSession
        self.playUI = playUI
        self.cardSession = cardSession
        self.listSession = listSession
        self.settingSession = settingSession
        self.colorState = colorState
        self.logic = logic
        self.uiRepository = uiRepository
    }

    // UIをリセット、保存すべきものは保存
    func updateView() async {
        playUI = PlayUI()
        playUI.screenSlots = logic.firstCard(cards: cardSession.cards, mode: playSession.mode)
        playSession.shownCount = playUI.screenSlots.compactMap { $0 }.count
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
        let nextCard = logic.nextCard(
            cards: cardSession.cards,
            looping: playSession.looping,
            mode: playSession.mode,
            shownCount: playSession.shownCount,
            mistakeCards: &playSession.mistakeCards
        )
        Task { @MainActor in
            await DelayController.wait(seconds: Double(settingSession.setting.waitTime))
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
    func mistakeTask(slotIndex: Int) async {
        guard let slot = playUI.screenSlots[slotIndex] else { return }
        if let index = cardSession.cards.firstIndex(where: { $0.id == slot.card.id }) {
            cardSession.cards[index].mistake = true
        }
        playSession.mistakeCards.append(slot.card.id)
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
