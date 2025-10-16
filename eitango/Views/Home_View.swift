import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: PlayViewModel
    
    func EnfontSize(i: String) -> Int {
        if(i.count > 15){
            return 30
        }
        else if(i.count > 11){
            return 40
        }
        else{
            return 50
        }
    }
    
    func JpfontSize(i: String) -> Int{
        if(i.count > 7){
            return 30
        }
        else{
            return 40
        }
    }
    
    func Enopacity(y: Bool, rev: Bool) -> Double{
        let i: Double = y ? rev ? 1 : 0 : vm.reverse ? 0 : 1
        return i
    }
    
    func Jpopacity(y: Bool, rev: Bool) -> Double{
        let i: Double = y ? rev ? 0 : 1 : vm.reverse ? 1 : 0
        return i
    }
    
    func FlippTask(i: Int) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * UInt64(vm.waittime)))
            //UInt64型のnsしか受け取らないキモい関数
            vm.yy += 1
            if 4 + vm.yy < vm.English.count {
                vm.Enlist[i] = vm.English[4 + vm.yy]
                vm.Jplist[i] = vm.Japanese[4 + vm.yy]
                vm.isFlipped[i] = false
                //残ったカードを表示する処理
            }else if !vm.finish {
                vm.Enlist[i] = "-"
                vm.Jplist[i] = "-"
                vm.Finishlist[i] = true
                vm.jj += 1
            }
            if vm.jj >= 4 {
                vm.finish = true
            }
        }
    }
    
    func finishAction(i: Int){
        
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                TabView {  // タブビューを作成
                    VStack{
                        ZStack{
                            HStack{
                                Spacer()  // 左側のスペーサーでPickerを中央に寄せる
                                NavigationLink(destination: AddCardlist()){
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding(.trailing, 50)  // 右だけ10ポイント
                        }.frame(height: 70)
                        List{
                            ForEach(0..<vm.tangotyou.count, id: \.self) { i in
                                HStack {
                                    Spacer()
                                    ChecklistView(
                                        i: i,
                                        title: vm.tangotyou[i],
                                        Font: JpfontSize(i: vm.tangotyou[i]),
                                        wid: Double(geo.size.width * 0.85),
                                        hgt: Double(geo.size.height * 0.18)
                                    ) // 他の配列も同様に同期して削除
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete { indices in
                                vm.tangotyou.remove(atOffsets: indices)
                            }
                            //indicesは削除される要素の位置を示している
                            //atOffsetsで削除＆再描画
                        }
                        .listStyle(PlainListStyle())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .tabItem {  // タブのアイテム設定
                        Image(systemName: "pencil.and.ellipsis.rectangle")
                        Text("Edit")  // お気に入りタブのラベル
                    }
                    CardView()
                        .environmentObject(vm)
                        .tabItem { // タブのアイテム設定
                            Image(systemName: "play") // 家のアイコン
                            Text("Play") // ホームタブのラベル
                        }
                }
            }
        }
    }
}
