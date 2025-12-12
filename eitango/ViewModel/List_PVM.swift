import SwiftUI
import CoreData

extension PlayViewModel{
    
    func loadCardList() -> [CardlistEntity] {//戻り値はCardlistEntityの配列
        // CoreData操作の要となる「コンテキスト」を取得します。
        // コンテキストは「データベースとの橋渡し役」であり、データの読み書きを管理する重要な存在です。
        let context = PersistenceController.shared.container.viewContext
        
        // 取得したいエンティティ（データの種類）を指定するリクエストを作成します。
        // ここではCardlistEntity（単語リスト）を取得するためのリクエストを生成。
        let request: NSFetchRequest<CardlistEntity> = CardlistEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardlistEntity.createdAt, ascending: false)]
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
    
}
