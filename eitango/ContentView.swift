import SwiftUI

struct CardlistView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let i: Int
    let title: String
    let Font: Int
    let wid : Double
    let hgt : Double
    
    var body: some View {
        VStack{
            ZStack{
                ForEach(0..<7){ z in
                    Text("")
                        .frame(width: wid, height: hgt)
                        .background(Color.gray.opacity(colorScheme == .dark ? 0.25 : 0.1))
                        .cornerRadius(20)
                        .offset(y: Double(z) * 5 + 5)  // 下に少しずつずらす
                        .scaleEffect(1 - Double(z) * 0.01)  // 奥のカードを少し小さく
                        .zIndex(Double(z))  // 手前順に表示
                }
                Text(title)
                    .font(.system(size: CGFloat(Font)))
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(width: wid, height: hgt)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.6 : 0.2))
                    .cornerRadius(20)
                    .zIndex(100)
            }
            .frame(height: hgt + 30)  // 山札全体の高さ調整
            .padding(.bottom,10)
        }
    }
}
//カード用(型推論エラーが出たので外に出した）
struct CardView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let i: Int
    let eng: String
    let jp: String
    let isFlipped: Bool
    let reverse: Bool
    let enFont: Int
    let jpFont: Int
    let enOpacity: Double
    let jpOpacity: Double
    let wid : Double
    let hgt : Double
    let fin: Bool
    let finish: Bool
    let flip: () -> Void//返り値も引数もないことを示している（呼び出すと何か動く関数）
    let finishChose: () -> Void

    var body: some View {
        VStack {
            ZStack {
                Text(eng)
                    .font(.system(size: CGFloat(enFont)))
                    .foregroundStyle(fin ? Color.accentColor : reverse ? .red : (colorScheme == .dark ? .white : .black))
                    .frame(width: wid, height: hgt)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15))
                    .cornerRadius(20)
                    .opacity(enOpacity)
                    .scaleEffect(x: reverse ? -1 : 1, y: 1)
                Text(jp)
                    .font(.system(size: CGFloat(jpFont)))
                    .foregroundStyle(fin ? .blue : reverse ? (colorScheme == .dark ? .white : .black) : .red)
                    .frame(width: wid, height: hgt)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15))
                    .cornerRadius(20)
                    .opacity(jpOpacity)
                    .scaleEffect(x: reverse ? 1 : -1, y: 1)
            }
            .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.easeInOut(duration: 0.5), value: isFlipped)
            .onTapGesture {
                if finish{
                    finishChose()
                }
                else{
                    flip()
                }
            }//ここで親から渡された処理を行う
        }
    }
}

struct ContentView: View {
    @State var reverse = false
    // トグルの状態を保持するための変数
    //@Stateをつけることでこの変数が変わったときに勝手に再描画される（setStateみたいなもん）
    @State private var number = 0
    //Pickerの状態を保持
    @State private var isFlipped = Array(repeating: false, count: 4)
    //カードの裏返しを監視
    @State private var Enlist = Array(repeating: "none", count: 4)
    @State private var Jplist = Array(repeating: "none", count: 4)
    //実際に表示を担当するリスト
    
    @State private var Finishlist = Array(repeating: false, count: 4)
    //終わったカードがtrueになる

        
    @State var tangotyou = ["単語帳１","単語帳２","単語帳３","単語帳４","デスノート"]
    let English = ["fuck you","Swift","Flutter","Thank you","React","Gfffffffffffffff","N"]
    let Japanese = ["死ね","スウィフト","フラッター","ありがとう","難しい","ゴキブリ","ニュートン"]
    
    let waittime = 3
    
    @State var yy = 0
    //単語帳のリスト操作用の変数
    @State var jj = 0
    //単語帳の終わりを検知するための変数
    @State var finish = false
    
    init() {
        _Enlist = State(initialValue: Array(English.prefix(4)) + Array(repeating: "", count: max(0, 4 - English.prefix(4).count)))
        //_Englistが常に4要素になるように、要素が足りない場合は""で埋める
        //State(initialValue:)は@State変数の初期値を動的に設定する方法
        _Jplist = State(initialValue: Array(Japanese.prefix(4)) + Array(repeating: "", count: max(0, 4 - Japanese.prefix(4).count)))
    }
    
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
                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
                (Enlist[0], Jplist[0]) = ("次の単語帳をやる", "次の単語帳をやる")
                (Enlist[1], Jplist[1]) = ("もう一度やる", "もう一度やる")
                (Enlist[2], Jplist[2]) = ("シャッフル", "シャッフル")
                (Enlist[3], Jplist[3]) = ("終了", "終了")
                finish = true
            }
        }
    }
    
    func finishAction(i: Int){
        
    }
    
    var body: some View {
        GeometryReader { geo in
            TabView {  // タブビューを作成
                VStack{
                    ZStack{
                        HStack{
                            Spacer()  // 左側のスペーサーでPickerを中央に寄せる
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.accentColor)
                                
                        }
                        .padding(.trailing, 50)  // 右だけ10ポイント
                    }.frame(height: 70)
                    List{
                        ForEach(0..<tangotyou.count, id: \.self) { i in
                            HStack {
                                Spacer()
                                CardlistView(
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

#Preview {
    ContentView()  // プレビュー用にContentViewを表示
}
