import SwiftUI

struct ContentView: View {
    @State var reverse = false
    // トグルの状態を保持するための変数
    //@Stateをつけることでこの変数が変わったときに勝手に再描画される（setStateみたいなもん）
    @State private var number = 0
    //Pickerの状態を保持
    @State private var isFlipped = Array(repeating: false, count: 4)
    //カードの裏返しを監視
    @State private var Englist = Array(repeating: "none", count: 4)
    @State private var Jplist = Array(repeating: "none", count: 4)
    //実際に表示を担当するリスト
    
    let tangotyou = ["単語帳１","単語帳２"]
    let English = ["fuck you","Swift","Flutter","Thank you","React","G","N"]
    let Japanese = ["死ね","スウィフト","フラッター","ありがとう","難しい","ゴキブリ","ニュートン"]
    
    let waittime = 1
    
    var yy = 0
    //単語帳のリスト操作用の変数
    var jj = 0
    //単語帳の終わりを検知するための変数
    var finish = false
    
    init() {
        _Englist = State(initialValue: Array(English.prefix(4)) + Array(repeating: "", count: max(0, 4 - English.prefix(4).count)))
        //_Englistが常に4要素になるように、要素が足りない場合は""で埋める
        //State(initialValue:)は@State変数の初期値を動的に設定する方法
        _Jplist = State(initialValue: Array(Japanese.prefix(4)) + Array(repeating: "", count: max(0, 4 - Japanese.prefix(4).count)))
    }
    
    
    

    var body: some View {
        TabView {  // タブビューを作成
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
                }.frame(maxHeight: 70)
                ForEach(0..<4){i in
                    VStack{
                        ZStack{
                            Text("\(Englist[i])")
                                .font(.system(size:English[i].count > 11 ? English[i].count > 15 ? 30 : 40 : 50))
                                .foregroundStyle(reverse ? .red : .black)
                                .frame(width: 350, height: 140)
                                .background(Color.gray.opacity(0.15)) // opacityを0.15に設定してグレーをとても薄くしています
                                .cornerRadius(20)
                                .opacity(isFlipped[i] ? reverse ? 1 : 0 : reverse ? 0 : 1)
                                .scaleEffect(x: reverse ? -1 : 1, y: 1)
                                //透明度を制御する
                            Text("\(Jplist[i])")
                                .font(.system(size:Japanese[i].count > 7 ? 30 : 40))
                                .foregroundStyle(reverse ? .black : .red)
                                .frame(width: 350, height: 140)
                                .background(Color.gray.opacity(0.15)) // opacityを0.15に設定してグレーをとても薄くしています
                                .cornerRadius(20)
                                .opacity(isFlipped[i] ? reverse ? 0 : 1 : reverse ? 1 : 0)
                                .scaleEffect(x: reverse ? 1 : -1, y: 1)
                        }
                        .rotation3DEffect(
                            .degrees(isFlipped[i] ? -180 : 0), axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(.easeInOut(duration: 0.5), value: isFlipped[i])
                        .onTapGesture{
                            isFlipped[i] = true
                            Task {
                                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * UInt64(waittime)))
                                //UInt64型のnsしか受け取らないキモい関数
                                yy += 1
                                if(4 + yy < English.count){
                                    Englist[i] = English[4 + yy]
                                    Jplist[i] = Japanese[4 + yy]
                                }else{
                                    Englist[i] = "finish!"
                                    Jplist[i] = "おしまい！"
                                    jj += 1
                                    if(jj >= 4){
                                        finish = true
                                    }
                                }
                                
                                
                            }
                            
                        }
                    }
                }
                .padding(.bottom,10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .tabItem {  // タブのアイテム設定
                Image(systemName: "house")  // 家のアイコン
                Text("Home")  // ホームタブのラベル
            }

            
            VStack {  // 縦に並べるビュー
                Text("Favorites Placeholder").glassEffect()  // お気に入りのプレースホルダーにガラス効果を適用
            }
            .tabItem {  // タブのアイテム設定
                Image(systemName: "pencil.and.ellipsis.rectangle")
                Text("Edit")  // お気に入りタブのラベル
            }
        }
    }
}

#Preview {
    ContentView()  // プレビュー用にContentViewを表示
}
