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
                    EditView()
                        .environmentObject(vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {  // タブのアイテム設定
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Edit")  // お気に入りタブのラベル
                    }
                    PlayView()
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
