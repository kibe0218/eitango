import Foundation

class SessionEngine {
    
    //order基準
    private func nextOrderCard(
        flippedCard: Card,
        cards: [Card],
    ) -> Card? {
        var best: Card?
        for card in cards {
            if card.order > flippedCard.order {
                if best == nil || card.order < best!.order {
                    best = card
                }
            }
        }
        return best
    }
    
    //index基準
    private func nextIndexCard(
        flippedCard: Card,
        cards: [Card]
    ) -> Card? {
        guard let flippedIndex = cards.firstIndex(where: {$0.id == flippedCard.id}) else { return nil
        }
        let nextIndex = flippedIndex + 1
        guard nextIndex < cards.count else { return nil }
        return cards[nextIndex]
    }
    
    //ループ処理
    private func loopingCard(
        mode: SessionMode,
        cards: [Card],
    ) -> Card? {
        switch mode {
        case .ordered:
            return cards.min(by: {$0.order < $1.order})
        case .shuffled:
            return cards.first
        }
    }
    
    //間違えたカード処理
    private func nextMistakeCard (
        flippedCard: Card,
        mistakeCards: [Card]
    ) -> Card? {
        nextOrderCard(flippedCard: flippedCard, cards: mistakeCards)
    }
    
    //次のカード
    func nextCard(
        cards: [Card],
        mistakeCards: [Card],
        looping: Bool,
        mode: SessionMode,
        flippedCard: Card,
    ) -> Card? {
        let next: Card?
        switch mode {
        case .ordered:
            next = nextOrderCard(flippedCard: flippedCard, cards: cards)
        case .shuffled:
            next = nextIndexCard(flippedCard: flippedCard, cards: cards)
        }
        if let next {
            return next
        }
        if let mistake = nextMistakeCard(
            flippedCard: flippedCard,
            mistakeCards: mistakeCards
        ) {
            return mistake
        }
        if looping {
            return loopingCard(mode: mode, cards: cards)
        }
        return nil
    }
}
