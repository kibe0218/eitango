import SwiftUI
import Combine

struct CardsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    @StateObject var keyboard = KeyboardObserver()
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var geo_height: CGFloat = 0
    @State private var ing: Int = 0
    @State private var keeplistid: String = ""
    
    @Binding var path: NavigationPath
    
    @State private var newWord: String = ""
    //デフォルトはen->ja
    func translateTextWithGAS(_ text: String, source: String = "en", target: String = "ja") async throws -> String {
        // addingPercentEncodingで＋＋などの特殊文字を安全な文字列に変換
        // withAllowedCharacters: .urlQueryAllowedは空白や？を%26などに変換
        // withAllowedChaaractersはURLに安全にう目込むためのルールを指定するところ
        let urlString = "https://script.google.com/macros/s/AKfycbxotVWEIFCz2YhhUZSdPJ7jkYlQKj2W2ya7QWRlFiGixeRaoFg7P9E75HfgQEN-GakP/exec?text=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&source=\(source)&target=\(target)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // レスポンスデータをJSONとしてデコードし、ステータスコードと翻訳結果を抽出する、辞書型
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let code = json["code"] as? Int,
            code == 200,
            let translated = json["text"] as? String { // 翻訳テキストを取得
            return translated.removingPercentEncoding ?? translated
        } else {
            throw NSError(domain: "TranslationAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "翻訳失敗"])
        }
    }
    
    var body: some View {
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
                            .scrollContentBackground(.hidden)
                        }
                        ForEach(vm.Cards, id: \.objectID) { card in
                            ItemView(card: card, width: geo.size.width, height: geo_height, title: vm.fetchListsFromCoreData().first(where: { $0.id == vm.selectedListId })?.title ?? "")                                .environmentObject(vm)
                        }
                        .onDelete { indexSet in
                            indexSet
                                .map { vm.Cards[$0] }
                                .forEach { card in
                                    vm.deleteCardAPI(userId: vm.userid, listId: vm.selectedListId ?? "", cardId: card.id ?? "")
                                }
                        }
                        .listRowSeparator(.hidden)
                        .scrollContentBackground(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.bottom, 10)
                    }
                    .listStyle(PlainListStyle())
                    TextField("add a new card...", text: $newWord)
                        .keyboardType(.asciiCapable)//英語キーボードを表示
                        .focused($isTextFieldFocused)
                        .padding(.all,40)
                        .onSubmit {
                            let trimmedWord = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedWord.isEmpty && trimmedWord != "-" else { return }
                            ing += 1
                            newWord = ""
                            isTextFieldFocused = true
                            Task { // submitごとにTask作成
                                let currentListId = vm.selectedListId
                                do {
                                    if let encodedWord = trimmedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                        let translated = try await translateTextWithGAS(encodedWord, source: "en", target: "ja")
                                        DispatchQueue.main.async {
                                            if let listId = currentListId {//nil安全策
                                                vm.addCardAPI(listId: listId, en: trimmedWord, jp: translated)
                                                ing -= 1
                                                vm.updateView()
                                            } else {
                                                print("🟡 listIdが無効のためカード追加できません")
                                            }
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
