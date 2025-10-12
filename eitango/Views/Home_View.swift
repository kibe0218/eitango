import SwiftUI

struct HomeView: View {
    @Binding var English: [String]
    @Binding var Japanese: [String]
    @Binding var reverse: Bool
    @Binding var number: Int
    @Binding var waittime: Int
    @Binding var isFlipped: [Bool]
    @Binding var Enlist: [String]
    @Binding var Jplist: [String]
    @Binding var Finishlist: [Bool]
    @Binding var tangotyou: [String]
    @Binding var yy: Int
    @Binding var jj: Int
    @Binding var finish: Bool
    
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
        let i: Double = y ? rev ? 1 : 0 : reverse ? 0 : 1
        return i
    }
    
    func Jpopacity(y: Bool, rev: Bool) -> Double{
        let i: Double = y ? rev ? 0 : 1 : reverse ? 1 : 0
        return i
    }
    
    func FlippTask(i: Int) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * UInt64(waittime)))
            //UInt64型のnsしか受け取らないキモい関数
            yy += 1
            if 4 + yy < English.count {
                Enlist[i] = English[4 + yy]
                Jplist[i] = Japanese[4 + yy]
                isFlipped[i] = false
                //残ったカードを表示する処理
            }else if !finish {
                Enlist[i] = "finish!"
                Jplist[i] = "おしまい！"
                Finishlist[i] = true
                jj += 1
            }
            if jj >= 4 {
                finish = true
                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
                (Enlist[0], Jplist[0]) = ("次の単語帳", "次の単語帳")
                (Enlist[1], Jplist[1]) = ("もう一度", "もう一度")
                (Enlist[2], Jplist[2]) = ("シャッフル", "シャッフル")
                (Enlist[3], Jplist[3]) = ("終了", "終了")
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
                            ForEach(0..<tangotyou.count, id: \.self) { i in
                                HStack {
                                    Spacer()
                                    ChecklistView(
                                        i: i,
                                        title: tangotyou[i],
                                        Font: JpfontSize(i: tangotyou[i]),
                                        wid: Double(geo.size.width * 0.85),
                                        hgt: Double(geo.size.height * 0.18)
                                    ) // 他の配列も同様に同期して削除
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete { indices in
                                tangotyou.remove(atOffsets: indices)
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
                    VStack{
                        ZStack{
                            HStack{
                                Spacer()  // 左側のスペーサーでPickerを中央に寄せる
                                Picker("単語帳", selection: $number){
                                    ForEach(0..<tangotyou.count, id :\.self){
                                        index in Text(tangotyou[index]).tag(index)
                                    }
                                }
                                Spacer()
                            }
                            .padding(20)
                            HStack{
                                Spacer()  // 左側のスペーサーでPickerを中央に寄せる
                                Toggle("",isOn: $reverse)
                            }
                            .padding(30)
                        }.frame(height: 70)
                        ForEach(0..<4) { i in
                            CardView(
                                i: i,
                                eng: Enlist[i],
                                jp: Jplist[i],
                                isFlipped: isFlipped[i],
                                reverse: reverse,
                                enFont: EnfontSize(i: Enlist[i]),
                                jpFont: JpfontSize(i: Jplist[i]),
                                enOpacity: Enopacity(y: isFlipped[i], rev: reverse),
                                jpOpacity: Jpopacity(y: isFlipped[i], rev: reverse),
                                wid: Double(geo.size.width * 0.85),
                                hgt: Double(geo.size.height * 0.18),
                                fin: Finishlist[i],
                                finish: finish,
                                flip: { isFlipped[i] = true; FlippTask(i: i) },
                                finishChose: { finishAction(i: i) }
                            )
                        }
                        .padding(.bottom,10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .tabItem {  // タブのアイテム設定
                        Image(systemName: "play")  // 家のアイコン
                        Text("Play")  // ホームタブのラベル
                    }
                }
            }
        }
    }
    
}
