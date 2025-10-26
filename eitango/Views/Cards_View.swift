import SwiftUI
import Combine

// キーボードの高さを監視するObservableObject


struct CardsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    @StateObject var keyboard = KeyboardObserver()
    @FocusState private var isTextFieldFocused: Bool
    
    let title: String
    @State private var geo_height: CGFloat = 0
    @State private var ing: Int = 0
    @Binding var path: NavigationPath
    
    @State private var newWord: String = ""
    
    //デフォルトはen->ja
    func translateTextWithGAS(_ text: String, source: String = "en", target: String = "ja") async throws -> String {
        let urlString = "https://script.google.com/macros/s/AKfycbwQILljpasT8-lGpErSksKhuuJTfp3_RvSv9WZvUN9mS3ogHKgwGWkmBBbimeH0LHVA/exec?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&source=\(source)&target=\(target)"
        // 入力されたテキスト・言語情報をURLパラメータとしてGASのAPIエンドポイントに組み込む \()でURLに変数を組み込んでる
        // addingPercentEncodingで＋＋などの特殊文字を安全な文字列に変換
        // withAllowedCharacters: .urlQueryAllowedは空白や？を%26などに変換
        // withAllowedChaaractersはURLに安全にう目込むためのルールを指定するところ
            
        
        guard let url = URL(string: urlString) else { // 文字列からURL型を生成し、失敗した場合はエラーを投げる
            // guardはSwiftの条件をチェックして早期退出する文 // if文と違い、elseが必須
            throw URLError(.badURL) // この後関数を終了
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        // URLSessionで非同期リクエストを送り、レスポンスデータを取得する
        //URLSeesio.shared->iOS標準のネットワーク通信を行うクラス
        //.data(from: url)->指定したURLからデータを取得するメソッド
        //dataだけ受け取り、responseは受け取らないから_
        //簡単
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            // レスポンスデータをJSONとしてデコードし、ステータスコードと翻訳結果を抽出する
            //JSONserialization.jsonObject(with:)でサーバーから取得したバイト列のdataをswiftの型に変換する
            //バイト型はサーバから受け取った生のデータのこといろんなデータをバイト単位で格納（swiftではData型で表現される）
            //try?は失敗したらnilになる安全な書き方
            //as? [String:A Any]はJSONオブジェクトを辞書型にキャスト
            //Any型とは全ての型を受け取ることができる型
            let code = json["code"] as? Int,
            // ステータスコードを取得
            code == 200, // 成功かどうか判定
            let translated = json["text"] as? String { // 翻訳テキストを取得
            return translated.removingPercentEncoding ?? translated
            // 翻訳結果を返す（デコード失敗時は元の文字列を返す）
        } else {
            throw NSError(domain: "TranslationAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "翻訳失敗"]) // エラー時はエラーメッセージを含むNSErrorを投げる
        }
    }
    
    var body: some View {
        // NavigationStackで画面を積んでいく
        NavigationStack(path: $path) {
            GeometryReader { geo in
                VStack{
                    List {
                        ForEach(vm.cards, id: \.objectID) { card in
                            ItemView(card: card, width: geo.size.width, height: geo_height)
                                .environmentObject(vm)
                        }
                        .onDelete { indices in
                            // Core Data側から削
                            let cardsToDelete = indices.map { vm.cards[$0] }
                            for card in cardsToDelete {
                                vm.deleteCard(card)
                            }
                            // Core Dataの削除後に配列を再取得
                            vm.cards = vm.loadCards(title: title)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.bottom, 10)
                    }
                    .listStyle(PlainListStyle())
                    TextField("add a new card...", text: $newWord)
                        .keyboardType(.asciiCapable)//英語キーボードを表示
                        .focused($isTextFieldFocused)
                        .padding(.all,40)
                        .onSubmit {
                            ing += 1
                            print("翻訳中",ing)
                            // 空文字防止
                            let trimmedWord = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
                            //trimmingCharacters(in:)は指定した文字セットを文字列の先頭と末尾から削除
                            //.whitespacesAndNewlines空白と改行を削除
                            guard !trimmedWord.isEmpty && trimmedWord != "-" else { return }
                            //文字列がからではないことと-だけの文字列でないことを確認(終了マークと紛らわしい）
                            // 入力欄をクリア
                            newWord = ""
                            isTextFieldFocused = true
                            if let list = vm.loadCardList().first(where: { $0.title == title }) {
                                Task {
                                    do {
                                        if let encodedWord = trimmedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                            //%18とかにするのがaddingPercentEncding
                                            //urlQueryAllowedはURLのクエリ部分で使える文字ののみということを定義している
                                            let translated = try await translateTextWithGAS(encodedWord, source: "en", target: "ja")
                                            ing -= 1
                                            print("翻訳結果: \(translated)") // 例: "こんにちは"
                                            print("翻訳中:",ing)
                                            DispatchQueue.main.async {
                                            //DispatchQueue.mainとはSwiftのメインスレッドを示す
                                                vm.addCard(to: list, en: trimmedWord, jp: translated)
                                                vm.updateView()
                                            }
                                        } else {
                                            print("Encoding failed for input word")
                                        }
                                    } catch {
                                        print("翻訳失敗: \(error)")
                                    }
                                }
                            }
                        }
                        .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.18, alignment: .center)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .background(
                            Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15)
                        )
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .animation(.easeInOut, value: keyboard.keyboardHeight)
                .onAppear {
                    geo_height = geo.size.height
                }
            }
            .foregroundColor(.accentColor)
            .onAppear {
                vm.title = title
                vm.cards = vm.loadCards(title: title)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
    }
}

struct ItemView: View{
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    let card: CardEntity
    let width: Double
    let height: Double
    
    var body: some View {
        VStack{
            Text(card.en ?? "")
                .font(.system(size: CGFloat(vm.EnfontSize(i: card.en ?? ""))))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            Text(card.jp ?? "")
                .font(.system(size: 30))
                .foregroundStyle(Color.gray)
        }
        .frame(width: width * 0.85, height: height * 0.18, alignment: .center)
        .background(
            Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15)
        )
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
        .onTapGesture {
            // ここにタップ時の処理を書く
        }
    }
}
