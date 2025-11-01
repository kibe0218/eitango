import SwiftUI

struct EditView: View {
    @EnvironmentObject var vm: PlayViewModel
    @StateObject var keyboard = KeyboardObserver()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAlert = false
    @State private var title: String = ""
    @State private var navigateToCardList = false//画面遷移を監視
    @State private var CardListTitle: String = ""
    @State private var path = NavigationPath()
    
    var body: some View {
        
        NavigationStack{
            GeometryReader { geo in
                VStack{
                    ZStack{
                        HStack{
                            Button(action: {
                                showAlert = true
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.title)
                                    .foregroundStyle(vm.customaccentColor)
                            }
                            Spacer()  // 左側のスペーサーでPickerを中央に寄せる
                            Button(action: {
                                showAlert = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundStyle(vm.customaccentColor)
                            }
                            .alert("新しい単語帳を作成", isPresented: $showAlert) {
                                TextField("タイトル", text: $title)
                                Button("キャンセル", role: .cancel) {
                                    showAlert.toggle()
                                }
                                Button("OK") {
                                    guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                    _ = vm.addCardList(title: title)
                                    CardListTitle = title
                                    title = ""
                                    vm.noshuffleFlag = true
                                    vm.updateView()
                                    navigateToCardList = true
                                }
                                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                                //trimmingで先頭や末尾にある特定の文字を削除してくれる
                                //isEmptyでから文字列をtrueにしてしまう->disabledでボタンを無効化
                            }
                        }
                        .padding(.horizontal, 50)
                    }.frame(height: 70)
                    List{
                        ForEach(0..<vm.tangotyou.count, id: \.self) { i in
                            HStack {
                                Spacer()
                                VStack{
                                    ZStack{
                                        ForEach(0..<6, id: \.self){ z in
                                            CardListView(i: i, z: z, width: geo.size.width, height: geo.size.height)
                                                .environmentObject(vm)
                                        }
                                        Text(vm.tangotyou[i])
                                            .font(.system(size: CGFloat(vm.JpfontSize(i: vm.tangotyou[i]))))
                                            .foregroundStyle(vm.cardfrontColor)
                                            .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.18)
                                            .background(vm.cardColor)
                                            .cornerRadius(20)
                                            .zIndex(100)
                                    }
                                    .onTapGesture{
                                        CardListTitle = vm.tangotyou[i]
                                        vm.noshuffleFlag = true
                                        vm.updateView()
                                        navigateToCardList = true
                                    }
                                    .frame(height: geo.size.height * 0.18 + 30)
                                    .padding(.bottom,10)
                                }
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete { indices in
                            for index in indices {
                                let title = vm.tangotyou[index]
                                if let list = self.vm.loadCardList().first(where: { $0.title == title }) {
                                    vm.deleteCardList(list)
                                }
                            }
                            vm.tangotyou.remove(atOffsets: indices)
                        }
                        //indicesは削除される要素の位置を示している
                        //atOffsetsで削除＆再描画
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .background(vm.backColor.ignoresSafeArea())
        .onAppear{
            vm.colorS = colorScheme
        }
        .navigationDestination(isPresented: $navigateToCardList) {
            CardsView(title: CardListTitle, path: $path)
                .environmentObject(vm)
                .environmentObject(keyboard)
        }
    }
}

struct CardListView: View {
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let i: Int
    let z: Int
    let width: Double
    let height: Double
        
    var body: some View {
            Text("")
                .frame(width: width * 0.85, height: height * 0.18)
                .background(vm.cardlistmobColor)
                .cornerRadius(20)
                .offset(y: Double(z) * 5 + 5)
                .scaleEffect(1 - Double(z) * 0.01)
                .zIndex(Double(z))
    }
}
