import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: PlayViewModel
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                TabView {  // タブビューを作成
                    PlayView()
                        .environmentObject(vm)
                        .tabItem { // タブのアイテム設定
                            Image(systemName: "play") // 家のアイコン
                            Text("Play") // ホームタブのラベル
                        }
                    EditView()
                        .environmentObject(vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {  // タブのアイテム設定
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Edit")  // お気に入りタブのラベル
                        }
                }
                .onAppear{
                    vm.tangotyou = vm.loadCardList()
                        .sorted { ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast) }
                    //Date.distanPast->ありえる限り過去の日付
                    //nilのカードを最も古い扱いにする
                        .compactMap { $0.title ?? "" }
                    vm.Enlist = Array(vm.English.prefix(min(vm.English.count,4)))
                    vm.Jplist = Array(vm.Japanese.prefix(min(vm.Japanese.count,4)))
                    //conpactMapでタイトル配列に変換compactMapはnilが残らない,
                    //%0は配列の１つ１つの要素を指す省略名
                }
            }
        }
    }
}
