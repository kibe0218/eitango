import SwiftUI

struct CardsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    
    let title: String
    @Binding var path: NavigationPath
    
    @State private var newWord: String = ""


    var body: some View {
        NavigationStack(path: $path) {//NavigationStackで画面を積んでいく
            GeometryReader { geo in
                VStack {
                    ZStack {
                        HStack {
                            Spacer() // 左側のスペーサーでPickerを中央に寄せる
                            Toggle("", isOn: $vm.reverse)
                        }
                        .padding(30)
                    }
                    .frame(height: 70)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(0..<vm.English.count, id: \.self) { i in
                            ItemView(i: i,width: geo.size.width, height: geo.size.height)
                                .environmentObject(vm)
                        }
                        .onDelete { indices in
                            vm.English.remove(atOffsets: indices)
                            vm.Japanese.remove(atOffsets: indices)
                        }
                        .padding(.bottom, 10)
                        TextField("Add a new card", text: $newWord)
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
                    }
                }
                .frame(alignment: .top)
            }
            .navigationBarBackButtonHidden(true) // Hide back button
            .foregroundColor(.accentColor)
            .onAppear {
                // 1. タイトルに一致する単語帳を検索
                let cards = vm.loadCards(title: title)
                if cards.isEmpty {
                    vm.English = []
                    vm.Japanese = []
                } else {
                    vm.English = cards.compactMap { $0.en ?? "" }
                    vm.Japanese = cards.compactMap { $0.jp ?? "" }
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
