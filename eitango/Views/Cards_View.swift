import SwiftUI

struct CardsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    
    @FocusState private var isTextFieldFocused: Bool
    
    let title: String
    @Binding var path: NavigationPath
    
    @State private var newWord: String = ""
    
    func translateTextWithGAS(_ text: String, source: String = "en", target: String = "ja") async throws -> String {
        // 入力されたテキスト・言語情報をURLパラメータとしてGASのAPIエンドポイントに組み込む
        let urlString = "https://script.google.com/macros/s/AKfycbyEyNW2gf1PexlqfE6mhUa4QDIjF8N5E7vTHcWB35R_ZxvSdKgwjAPuWLgZEggTIKU/exec?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&source=\(source)&target=\(target)"
        
        // 文字列からURL型を生成し、失敗した場合はエラーを投げる
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // URLSessionで非同期リクエストを送り、レスポンスデータを取得する
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // レスポンスデータをJSONとしてデコードし、ステータスコードと翻訳結果を抽出する
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let code = json["code"] as? Int, // ステータスコードを取得
           code == 200, // 成功かどうか判定
           let translated = json["text"] as? String { // 翻訳テキストを取得
            return translated // 翻訳結果を返す
        } else {
            // エラー時はエラーメッセージを含むNSErrorを投げる
            throw NSError(domain: "TranslationAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "翻訳失敗"])
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {//NavigationStackで画面を積んでいく
            GeometryReader { geo in
                VStack{
                    List {
                        ForEach(vm.cards, id: \.self) { card in
                            ItemView(card: card, width: geo.size.width, height: geo.size.height)
                                .environmentObject(vm)
                        }
                        .onDelete { indices in
                            // Core Data側から削除
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
                    .frame(maxWidth: .infinity, alignment: .center)
                    TextField("add a new card...", text: $newWord)
                        .focused($isTextFieldFocused)
                        .padding(.all,40)
                        .onSubmit {
                            let trimmedWord = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedWord.isEmpty && trimmedWord != "-" else { return }//空文字防止
                            newWord = ""                 // 入力欄をクリア
                            isTextFieldFocused = true
                            if let list = vm.loadCardList().first(where: { $0.title == title }) {
                                Task {
                                    do {
                                        if let encodedWord = trimmedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                            let translated = try await translateTextWithGAS(encodedWord, source: "en", target: "ja")
                                            print("翻訳結果: \(translated)") // 例: "こんにちは"
                                            DispatchQueue.main.async {
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
                        .foregroundStyle(.black)
                        .background(
                            Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15)
                        )
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .foregroundColor(.accentColor)
            .onAppear {
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
        ZStack{
            Text(card.en ?? "")
                .font(.system(size: CGFloat(vm.EnfontSize(i: card.en ?? ""))))
                .foregroundStyle(.black)
                .frame(width: width * 0.85,height: height * 0.18, alignment: .center)
                .background(
                    Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15)
                )
                .cornerRadius(20)
                .scaleEffect(x: vm.reverse ? -1 : 1, y: 1)
                .frame(maxWidth: .infinity, alignment: .center)
                .onTapGesture {
                }
        }
    }
}
