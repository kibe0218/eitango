import SwiftUI

struct CardsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    
    @FocusState private var isTextFieldFocused: Bool
    
    let title: String
    @Binding var path: NavigationPath
    
    @State private var newWord: String = ""
    
    
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
                            guard !newWord.isEmpty && newWord != "-" else { return }//空文字防止
                            if let list = vm.loadCardList().first(where: { $0.title == title }) {
                                vm.addCard(to: list, en: newWord, jp: "日本語訳")
                                vm.updateView()
                                newWord = ""                 // 入力欄をクリア
                                isTextFieldFocused = true
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
