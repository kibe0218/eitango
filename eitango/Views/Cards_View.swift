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
    
    /// 🐙 新しい単語の送信入口
    func submitNewWord(_ word: String) {
        ing += 1
        Task {
            await translateAndAddCard(word)
        }
    }

    /// 🌍 翻訳してカードを追加する非同期処理
    func translateAndAddCard(_ word: String) async {
        guard let currentListId = vm.selectedListId else {
            print("🟡 listIdが無効のためカード追加できません")
            await MainActor.run {
                ing -= 1
            }
            return
        }

        do {
            let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let translated = try await vm.translateTextWithGAS(encodedWord, source: "en", target: "ja")

            await MainActor.run {
                vm.addCardAPI(listId: currentListId, en: word, jp: translated)
                ing -= 1
            }
        } catch {
            await MainActor.run {
                ing -= 1
                print("🟡 翻訳失敗: \(error)")
            }
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

                            newWord = ""
                            isTextFieldFocused = true

                            submitNewWord(trimmedWord)
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
