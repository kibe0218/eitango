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
                        ForEach(0..<vm.English.count, id: \.self) { i in
                            ItemView(i: i,width: geo.size.width, height: geo.size.height)
                                .environmentObject(vm)
                        }
                        .onDelete { indices in
                            for index in indices{
                                let card = vm.cards[index]
                                vm.deleteCard(card)
                            }
                            vm.English.remove(atOffsets: indices)
                            vm.Japanese.remove(atOffsets: indices)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.bottom, 10)
                    }
                    TextField("Add a new card", text: $newWord)
                        .focused($isTextFieldFocused)
                        .padding(.all,40)
                        .onSubmit {
                            guard !newWord.isEmpty else { return }//空文字防止
                            if let list = vm.loadCardList().first(where: { $0.title == title }) {
                                vm.addCard(to: list, en: newWord, jp: "日本語訳")
                                vm.English.append(newWord)   // 英語リストに追加
                                newWord = ""                 // 入力欄をクリア
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
                // 初期化：カード配列にタイトルに一致するカードを代入
                vm.cards = vm.loadCards(title: title)
                let cards = vm.cards
                if cards.isEmpty {
                    vm.English = []
                    vm.Japanese = []
                } else {
                    vm.English = cards.compactMap { $0.en ?? "" }
                    vm.Japanese = cards.compactMap { $0.jp ?? "" }
                }
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
    let i: Int
    let width: Double
    let height: Double
    
    var body: some View {
        Text(vm.English[i])
                .font(.system(size: CGFloat(vm.EnfontSize(i: vm.English[i]))))
                .foregroundStyle(.black)
                .frame(width: width * 0.85,height: height * 0.18)
                .background(
                    Color.gray.opacity(colorScheme == .dark ? 0.4 : 0.15)
                )
                .cornerRadius(20)
                .scaleEffect(x: vm.reverse ? -1 : 1, y: 1)
                .padding(.bottom,10)
        .onTapGesture {
        }
    }
}
