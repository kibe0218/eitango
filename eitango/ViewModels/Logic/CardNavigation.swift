import Foundation

class SessionEngine {
    
    // MARK: - Private Helpers
    
    // order基準最初4カード
    private func firstOrderCard(
        cards: [Card]
    ) -> [ScreenCard?] {
        let sortedCards = cards.sorted { $0.order < $1.order }
        var resultCards: [ScreenCard?] = sortedCards.prefix(4).map { card in
            ScreenCard(
                card: card,
                cardSide: .front,
                isFinished: false
            )
        }
        while resultCards.count < 4 {
            resultCards.append(nil)
        }
        return resultCards
    }
    
    // index基準最初4カード
    private func firstIndexCard(
        cards: [Card]
    ) -> [ScreenCard?] {
        var resultCards: [ScreenCard?] = cards.prefix(4).map { card in
            ScreenCard(
                card: card,
                cardSide: .front,
                isFinished: false
            )
        }
        while resultCards.count < 4 {
            resultCards.append(nil)
        }
        return resultCards
    }
    
    // order基準
    private func nextOrderCard(
        maxOrder: Int,
        cards: [Card],
    ) -> Card? {
        return cards
            .filter { $0.order > maxOrder }
            .min(by: { $0.order < $1.order })
    }
    
    // index基準
    private func nextIndexCard(
        maxIndex: Int,
        cards: [Card]
    ) -> Card? {
        let nextIndex = maxIndex + 1
        guard nextIndex < cards.count else { return nil }
        return cards[nextIndex]
    }
    
    // ループ処理
    private func loopingCard(
        mode: PlayMode,
        cards: [Card],
    ) -> Card? {
        switch mode {
        case .ordered:
            return cards.min {$0.order < $1.order}
        case .shuffled:
            return cards.first
        }
    }
    
    // 間違えたカード処理
    func nextMistakeCard(
        cards: [Card],
        mistakeCards: inout [String]
    ) -> Card? {
        guard !mistakeCards.isEmpty else { return nil }
        let id = mistakeCards.removeFirst()
        return cards.first { $0.id == id }
    }
    
    // 最初のカード
    func firstCard(
        cards: [Card],
        mode: PlayMode
    ) -> [ScreenCard?] {
        switch mode {
        case .ordered:
            return firstOrderCard(cards: cards)
        case .shuffled:
            return firstIndexCard(cards: cards)
        }
    }
    
    
    // 次のカード
    func nextCard(
        cards: [Card],
        looping: Bool,
        mode: PlayMode,
        shownCount: Int,
        mistakeCards: inout [String],
    ) -> Card? {
        let next: Card?
        switch mode {
        case .ordered:
            next = nextOrderCard(maxOrder: shownCount, cards: cards)
        case .shuffled:
            next = nextIndexCard(maxIndex: shownCount, cards: cards)
        }
        if let next {
            return next
        }
        if !mistakeCards.isEmpty
        {
            return nextMistakeCard(cards: cards, mistakeCards: &mistakeCards)
        }
        if looping {
            return loopingCard(mode: mode, cards: cards)
        }
        return nil
        
    }
}
