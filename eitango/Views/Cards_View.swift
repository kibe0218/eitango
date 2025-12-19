import SwiftUI
import Combine

struct CardsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    @StateObject var keyboard = KeyboardObserver()
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var geo_height: CGFloat = 0
    @State private var ing: Int = 0
    @Binding var path: NavigationPath
    
    @State private var newWord: String = ""
    //デフォルトはen->ja
    func translateTextWithGAS(_ text: String, source: String = "en", target: String = "ja") async throws -> String {
        let urlString = "https://script.google.com/macros/s/AKfycbxotVWEIFCz2YhhUZSdPJ7jkYlQKj2W2ya7QWRlFiGixeRaoFg7P9E75HfgQEN-GakP/exec?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&source=\(source)&target=\(target)"
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
                        if(ing != 0){
                            HStack{
                                Spacer()
                                Text("翻訳中: \(ing)件...")
                                    .font(.system(size: CGFloat(20)))
                                    .foregroundStyle(vm.customaccentColor)
                                    .frame(height: geo_height * 0.05, alignment: .center)
                                    .background(vm.backColor)
                                Spacer()
                            }
                            .listRowBackground(vm.backColor)
                            .listRowSeparator(.hidden)
                            .scrollContentBackground(.hidden) // ← これ大事！
                        }
                        ForEach(vm.Cards, id: \.objectID) { card in
                            ItemView(card: card, width: geo.size.width, height: geo_height, title: vm.fetchListsFromCoreData().first(where: { $0.id == vm.selectedListId })?.title ?? "")                                .environmentObject(vm)
                        }
                        .onDelete { indexSet in
                            indexSet
                                .map { vm.Cards[$0] }
                                .forEach { card in
                                    vm.deleteCardAPI(userId: "user1", listId: vm.selectedListId ?? "", cardId: card.id ?? "")
                                }
                        }
                        .listRowSeparator(.hidden)
                        .scrollContentBackground(.hidden) // ← これ大事！
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
                            //空白と改行を先頭と末尾から削除
                            let trimmedWord = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedWord.isEmpty && trimmedWord != "-" else { return }
                            newWord = ""
                            isTextFieldFocused = true
                            Task {
                                do {
                                    if let encodedWord = trimmedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                        //%18とかにするのがaddingPercentEncding
                                        //urlQueryAllowedはURLのクエリ部分で使える文字ののみということを定義している
                                        let translated = try await translateTextWithGAS(encodedWord, source: "en", target: "ja")
                                        ing -= 1
                                        DispatchQueue.main.async {
                                        //DispatchQueue.mainとはSwiftのメインスレッドを示す
                                            vm.addCardAPI(userId: "user1", listId: vm.selectedListId ?? "", en: trimmedWord, jp: translated)
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
                        .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.18, alignment: .center)
                        .foregroundStyle(vm.cardfrontColor)
                        .background(vm.cardColor)
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
                vm.colorS = colorScheme
                vm.Cards = vm.fetchCardsFromCoreData(listid: vm.selectedListId ?? "")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
            .onDisappear {
                vm.noshuffleFlag = false
            }
        }
        .background(vm.backColor.ignoresSafeArea())
    }
}

struct ItemView: View{
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var inputText: String = ""

    let card: CardEntity
    let width: Double
    let height: Double
    let title: String
    
    var body: some View {
        VStack{
            Text(card.en ?? "")
                .font(.system(size: CGFloat(vm.EnfontSize(i: card.en ?? ""))))
                .foregroundStyle(vm.cardfrontColor)
            TextField(
                "",
                text: $inputText,
                prompt: Text(card.jp ?? "").foregroundColor(vm.cardbackColor)
            )
            .font(.system(size: 30))
            .foregroundStyle(vm.cardbackColor)
                .onSubmit{
                    let trimmedWord = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedWord.isEmpty && trimmedWord != "-" else { return }
                    let pasten = card.en ?? ""
                    guard let listId = vm.selectedListId,
                          let cardId = card.id else { return }
                    vm.updateCardAPI(
                        userId: "user1",
                        listId: listId,
                        cardId: cardId,
                        en: pasten,
                        jp: trimmedWord,
                        createdAt: card.createdAt ?? Date()
                    )
                    vm.updateView()
                }
                .multilineTextAlignment(.center)
                .frame(height: height * 0.02)
        }
        .frame(width: width * 0.85, height: height * 0.18, alignment: .center)
        .background(vm.cardColor)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
