import SwiftUI
import Combine

struct CardView: View {
    @EnvironmentObject var vm: RootViewModel
    @EnvironmentObject var colorUIState: ColorUIState
    @EnvironmentObject var keyboard: KeyboardObserver
    
    @Environment(\.colorScheme) var scheme
    
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var geo_height: CGFloat = 0
    @State private var newWord: String = ""
    
    let list: CardList

    var body: some View {
        GeometryReader { geo in
            VStack{
                List {
                    if(vm.cardActions.translatingCount != 0){
                        HStack{
                            Spacer()
                            Text("翻訳中: \(vm.cardActions.translatingCount)件...")
                                .font(.system(size: CGFloat(20)))
                                .foregroundStyle(colorUIState.palette.customaccentColor)
                                .frame(height: geo_height * 0.05, alignment: .center)
                                .background(colorUIState.palette.backColor)
                            Spacer()
                        }
                        .listRowBackground(colorUIState.palette.backColor)
                        .listRowSeparator(.hidden)
                        .scrollContentBackground(.hidden)
                    }
                    ForEach(vm.cardSession.cards, id: \.id) { card in
                        CardItem(list: list, card: card, title: vm.listSession.lists.first(where: { $0.id == card.listId})?.title ?? "", width: geo.size.width, height: geo_height)
                    }
                    .onDelete { indices in
                        let cardsToDelete = indices.map { vm.cardSession.cards[$0] }
                        Task {
                            for card in cardsToDelete {
                                await vm.cardActions.delete(listId: list.id, id: card.id)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.bottom, 10)
                }
                .listStyle(PlainListStyle())
                TextField("add a new card...", text: $newWord)
                    .keyboardType(.asciiCapable)// 英語キーボードを表示
                    .focused($isTextFieldFocused)
                    .padding(.all,40)
                    .onSubmit {
                        let trimmedWord = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedWord.isEmpty && trimmedWord != "-" else { return }
                        isTextFieldFocused = true
                        Task {
                            await vm.cardActions.addTranslated(listId: list.id, source: "en", target: "jp", sourceWord: newWord)
                        }
                    }
                    .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.18, alignment: .center)
                    .foregroundStyle(colorUIState.palette.cardfrontColor)
                    .background(colorUIState.palette.cardColor)
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
            Task {
                vm.cardActions.fetchAllBy(listId: list.id)
                isTextFieldFocused = true
            }
        }
        .background(colorUIState.palette.backColor.ignoresSafeArea())
    }
}

struct CardItem: View {
    
    @EnvironmentObject var vm: RootViewModel
    @EnvironmentObject var colorUIState: ColorUIState
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var inputText: String = ""

    let list: CardList
    let card: Card
    let title: String
    let width: Double
    let height: Double
    
    var body: some View {
        VStack{
            Text(card.en)
                .font(.system(size: CGFloat(enFontSize(card.en))))
                .foregroundStyle(colorUIState.palette.cardfrontColor)
            TextField(
                "",
                text: $inputText,
                prompt: Text(card.jp).foregroundColor(colorUIState.palette.cardbackColor)
            )
            .font(.system(size: 30))
            .foregroundStyle(colorUIState.palette.cardbackColor)
            .onSubmit{
                let trimmedWord = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedWord.isEmpty && trimmedWord != "-" else { return }
                Task {
                    await vm.cardActions.update(
                        listId: list.id,
                        card: UpdateCardRequest(
                            id: card.id,
                            en: card.en,
                            jp: trimmedWord
                        )
                    )
                }
            }
            .multilineTextAlignment(.center)
            .frame(height: height * 0.02)
        }
        .frame(width: width * 0.85, height: height * 0.18, alignment: .center)
        .background(colorUIState.palette.cardColor)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
