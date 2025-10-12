import SwiftUI

struct ContentView: View {
    @State var reverse = false  // トグルの状態を保持するための変数
    @State private var number = 0
    //@Stateをつけることでこの変数が変わったときに勝手に再描画される（setStateみたいなもん）
    //Pickerの状態を保持
    @State private var isFlipped = Array(repeating: false, count: 4)
    //カードの裏返しを監視
    @State private var Enlist = Array(repeating: "none", count: 4)
    @State private var Jplist = Array(repeating: "none", count: 4)
    //実際に表示を担当するリスト

    @State private var Finishlist = Array(repeating: false, count: 4)
    //終わったカードがtrueになる
    @State var tangotyou = ["単語帳１", "単語帳２", "単語帳３", "単語帳４", "デスノート"]
    @State var English = [
        "Hello",
        "Swift",
        "Flutter",
        "Thank you",
        "React",
        "Wonderful",
        "Knowledge",
        "Peace",
        "Harmony",
        "Joy",
        "Courage",
        "Wisdom",
        "Friendship",
        "Adventure",
        "Inspiration",
        "Creativity",
        "Gratitude"
    ]
    @State var Japanese = [
        "こんにちは",
        "スウィフト",
        "フラッター",
        "ありがとうございます",
        "リアクト",
        "素晴らしい",
        "知識",
        "平和",
        "調和",
        "喜び",
        "勇気",
        "知恵",
        "友情",
        "冒険",
        "インスピレーション",
        "創造性",
        "感謝"
    ]

    @State var waittime = 3

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

    var body: some View {
        HomeView(
            English: $English,
            Japanese: $Japanese,
            reverse: $reverse,
            number: $number,
            waittime: $waittime,
            isFlipped: $isFlipped,
            Enlist: $Enlist,
            Jplist: $Jplist,
            Finishlist: $Finishlist,
            tangotyou: $tangotyou,
            yy: $yy,
            jj: $jj,
            finish: $finish
        )
    }

}

#Preview {
    AddCardlist()  // プレビュー用にContentViewを表示
}
