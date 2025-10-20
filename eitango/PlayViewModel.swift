import SwiftUI
import Combine
import CoreData

final class PlayViewModel: ObservableObject {
    @Published var Enlist: [String] = []
    @Published var Jplist: [String] = []
    @Published var Finishlist: [Bool] = [false, false, false, false]
    @Published var tangotyou: [String] = []
    @Published var cards: [CardEntity] = []
    
    @Published var reverse = false
    @Published var number = 0
    @Published var waittime = 2
    @Published var isFlipped: [Bool] = [false, false, false, false]
    @Published var yy = 1
    @Published var jj = 0
    @Published var finish = false
    @Published var title = ""
    @Published var cancelFlag = false
    
    init() {
            // 最初4単語をコピーして初期化
        updateView()
        let enbase = Array(cards.prefix(4)).compactMap { $0.en ?? "-" }
        let jpbase = Array(cards.prefix(4)).compactMap { $0.jp ?? "-" }
        Enlist = enbase + Array(repeating: "-", count: max(0, 4 - enbase.count))
        Jplist = jpbase + Array(repeating: "-", count: max(0, 4 - jpbase.count))
        for i in 0..<Enlist.count {
            if Enlist[i] == "-" {
                Finishlist[i] = true
                jj += 1
            }
            
        }
        //repeatingで繰り返し配列にaddする
        
    }
    
    func updateView() {
        yy = 1
        jj = 0
        finish = false
        
        tangotyou = loadCardList()
            .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
            .compactMap { $0.title ?? "" }
        if tangotyou.indices.contains(number) {
            //containsでそれが範囲に含まれるかチェック
            title = tangotyou[number]
        } else {
            title = tangotyou.first ?? ""
        }
        cards = loadCards(title: title)
        let enbase = Array(cards.prefix(4)).compactMap { $0.en ?? "-" }
        let jpbase = Array(cards.prefix(4)).compactMap { $0.jp ?? "-" }
        Enlist = enbase + Array(repeating: "-", count: max(0, 4 - enbase.count))
        Jplist = jpbase + Array(repeating: "-", count: max(0, 4 - jpbase.count))
        print(Enlist)
        print(cards)
        for i in 0..<Enlist.count {
            if Enlist[i] == "-" {
                Finishlist[i] = true
                jj += 1
            }
            else{
                Finishlist[i] = false
            }
        }
        isFlipped = [false, false, false, false]
        // Mark Finishlist[i] = true for each "-" element in Enlist
        print(Finishlist)
    }
    
    func loadCardList() -> [CardlistEntity] {//戻り値はCardlistEntityの配列
        // CoreData操作の要となる「コンテキスト」を取得します。
        // コンテキストは「データベースとの橋渡し役」であり、データの読み書きを管理する重要な存在です。
        let context = PersistenceController.shared.container.viewContext
        
        // 取得したいエンティティ（データの種類）を指定するリクエストを作成します。
        // ここではCardlistEntity（単語リスト）を取得するためのリクエストを生成。
        let request: NSFetchRequest<CardlistEntity> = CardlistEntity.fetchRequest()
        //let request: NSFetchRequest<Entity名> = Entity名.fetchReequest()
        
        do{
            // 実際にコンテキストを通じてデータベースからデータを取得します。
            // 取得に成功すれば配列で返却し、失敗した場合はcatch節へと進みます。
            let lists = try context.fetch(request)
            //context.fetch(request)で実際にリクエストを実行
            return lists
        }catch{
            // エラーが発生した場合、その詳細をコンソールに出力し、空の配列を返します。
            print("loadcardlisterror: \(error.localizedDescription)")
            return []
        }
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
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardEntity.createdAt, ascending: true)]
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
            print(newCard.en ?? "nil")
            //既存のCardlistEntityに追加するだけなのでreturn文は必要ない
        } catch {
            // 保存に失敗した場合はエラー内容をコンソールに出力します。
            print("addcarderror: \(error.localizedDescription)")
        }
    }
    
    func addCardList(title: String) -> CardlistEntity? {
        // 新しい単語リストを追加するためのコンテキストを取得します。
        let context = PersistenceController.shared.container.viewContext
        
        // CardlistEntity（単語リスト）の新規インスタンスをコンテキスト内に作成。
        let newList = CardlistEntity(context: context)
        
        // リストの各プロパティに値をセットします。
        newList.id = UUID()          // 一意な識別子
        newList.title = title        // タイトル名
        newList.createdAt = Date()   // 作成日時
        
        do {
            // 変更内容を永続化します。成功すれば新規リストを返却。
            try context.save()
            return newList
            //新しいカードリストを作らないといけないのでreturn必要あり
        } catch {
            // 保存失敗時はエラー内容を表示し、nilを返します。
            print("addcardlisterror: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteCardList(_ list: CardlistEntity) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(list)
        do {
            try context.save()
        } catch {
            print("deleteCardListError: \(error.localizedDescription)")
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
    
    func EnfontSize(i: String) -> Int {
        if i.count > 15 { return 30 }
        else if i.count > 11 { return 40 }
        else { return 50 }
    }

    func JpfontSize(i: String) -> Int {
        if i.count > 7 { return 30 } else { return 40 }
    }

    func Enopacity(y: Bool, rev: Bool) -> Double {
        return y ? (rev ? 1 : 0) : (reverse ? 0 : 1)
    }

    func Jpopacity(y: Bool, rev: Bool) -> Double {
        return y ? (rev ? 0 : 1) : (reverse ? 1 : 0)
    }

    func FlippTask(i: Int) {
        withAnimation {
            isFlipped[i] = reverse ? false : true
        }
        Task {
            let sleepInterval: UInt64 = 50_000_000 // 0.05 second
            var waited: UInt64 = 0
            let totalWait: UInt64 = UInt64(1_000_000_000 * UInt64(waittime))
            while waited < totalWait && !self.cancelFlag {
                try? await Task.sleep(nanoseconds: sleepInterval)
                waited += sleepInterval
            }
            if self.cancelFlag { return }
            let nextIndex = 4 + yy
            if i < Enlist.count && nextIndex < cards.count {
                Enlist[i] = cards[nextIndex].en ?? "-"
                Jplist[i] = cards[nextIndex].jp ?? "-"
                isFlipped[i] = reverse ? true : false
                yy += 1
            } else {
                if i < Enlist.count {
                    Enlist[i] = "-"
                    Jplist[i] = "-"
                    Finishlist[i] = true
                }
                jj += 1
            }
            if jj >= 4 {
                finish = true
            }
        }
    }
}

