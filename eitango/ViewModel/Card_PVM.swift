import SwiftUI
import CoreData

extension PlayViewModel{
    
    func fetchCards(userId: String, listId: String) {
        guard let url = URL(string:
            "http://localhost:8080/cards?userId=\(userId)&listId=\(listId)"
        ) else {
            print("URLエラー")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print("通信エラー: \(error)")
                return
            }
            guard let data = data else {
                print("データなしっピ")
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode([Card].self, from: data)
                //JSONをCard型に変換
                DispatchQueue.main.async {
                    let context = PersistenceController.shared.container.viewContext

                    // ① まずこのリストの既存カードを全部削除
                    if let targetList = self.loadCardList()
                        .first(where: { $0.id?.uuidString == listId }) {
                        let oldCards = self.loadCards(from: targetList)
                        //oldCardsの中身を全て消す
                        oldCards.forEach { context.delete($0) }
                        // ② Firestore のカードを CoreData に保存
                        for c in result {
                            let entity = CardEntity(context: context)
                            entity.id = UUID(uuidString: c.id)
                            entity.en = c.en
                            entity.jp = c.jp
                            entity.createdAt = c.createdAt
                            entity.cardlist = targetList
                        }

                        do {
                            try context.save()
                        } catch {
                            print("保存エラー: \(error)")
                        }

                        // ③ loadCards で表示データ更新
                        self.cards = self.loadCards(from: targetList)
                    }
                }

            } catch {
                print("デコード失敗: \(error)")
            }

        }.resume()//通信を開始する命令
    }
    
    func loadCards(title: String) -> [CardEntity] {
        if let list = loadCardList().first(where: { $0.title == title }) {
            return loadCards(from: list)
        } else {
            return []
        }
    }
    
    func loadCards(from list: CardlistEntity) -> [CardEntity] {
        // データの読み書きを司るコンテキストを取得します。
        let context = PersistenceController.shared.container.viewContext
        
        // CardEntity（単語カード）を取得するためのリクエストを作成します。
        let request: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        // 特定の単語リストに属するカードだけを取得するための条件（predicate）を設定。
        // これにより関連付けられたカードのみを抽出可能です。
        request.predicate = NSPredicate(format: "cardlist == %@", list)
        //NSPredicate(format:_:)はどんな条件でデータを絞り込むかを指定する条件文
        //cardlistというプロパティがlistと一緒のものだけ取得する
        //CoreDataには文字列で渡さないといけないだから""
        
        // 取得結果を作成日時の昇順でソートする指定を加えています。
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.createdAt, ascending: false)]
        //keyPath:どのプロパティで並び替えるか,ascending:昇順（true)or降順
        
        do{
            // コンテキストを通じてデータベースからカードを取得します。
            let cards = try context.fetch(request)
            return cards
        }catch{
            // エラーが起きた場合は詳細を表示し、空の配列を返します。
            print("loadcardserror: \(error.localizedDescription)")
            return []
        }
    }
    
    func addCard(to list: CardlistEntity, en: String, jp: String) {
        // 新たなデータを追加するためにコンテキストを取得します。
        // コンテキストは変更を一時的に保持し、最後に保存（commit）する役割を持ちます。
        let context = PersistenceController.shared.container.viewContext
        
        // 新しいCardEntity（単語カード）のインスタンスをコンテキスト内に作成します。
        let newCard = CardEntity(context: context)
        
        // 各プロパティに値を設定し、新カードの内容を整えます。
        newCard.id = UUID()          // 一意な識別子を付与
        newCard.en = en              // 英単語
        newCard.jp = jp              // 日本語訳
        newCard.createdAt = Date()   // 作成日時を現在時刻で設定
        newCard.cardlist = list      // 所属する単語リストを紐付け
        list.addToCards(newCard)
        
        do {
            // コンテキストに保持された変更を永続ストア（データベース）に保存します。
            // これにより実際にデータが書き込まれます。
            try context.save()
        } catch {
            // 保存に失敗した場合はエラー内容をコンソールに出力します。
            print("addcarderror: \(error.localizedDescription)")
        }
    }
    
    func deleteCard(_ card: CardEntity) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(card)
        do {
            try context.save()
        } catch {
            print("deleteCardError: \(error.localizedDescription)")
        }
    }
    
}
