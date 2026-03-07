import Foundation

class SessionEngine {
    
    //order基準
    func nextOrderCard(
        flippedCard: Card_ST,
        cards: [Card_ST],
    ) -> Card_ST? {
        return cards.first{ $0.order > flippedCard.order }
    }
    
    //index基準
    func nextIndexCard(
        flippedCard: Card_ST,
        cards: [Card_ST]
    ) -> Card_ST? {
        guard let flippedIndex = cards.firstIndex(where: {$0.id == flippedCard.id}) else { return nil
        }
        let nextIndex = flippedIndex + 1
        guard nextIndex < cards.count else { return nil }
        return cards[nextIndex]
    }
    
    //ループ処理
    func loopingCard(
        cards: [Card_ST],
    ) -> Card_ST? {
        return cards.first
    }
    
    //間違えたカード処理
    func mistakeCard (
        mistakeCards: [Card_ST]
    ) -> Card_ST? {
        return mistakeCards.first
    }
    
    //次のカード
    func nextCard(
        state: SessionState,
        flippedCard: Card_ST
    ) -> Card_ST? {
        let next: Card_ST?
        switch state.config.sessionMode {
        case .ordered:
            next = nextOrderCard(flippedCard: flippedCard, cards: state.config.sessionMode.cards)
        case .shuffled:
            next = nextIndexCard(flippedCard: flippedCard, cards: state.config.sessionMode.cards)
        }
        if let next {
            return next
        }
        if let mistake = mistakeCard(
            mistakeCards: state.mistakeCards
        ) {
            return mistake
        }
        if state.config.looping {
            return loopingCard(cards: state.config.sessionMode.cards)
        }
        return nil
    }
}
