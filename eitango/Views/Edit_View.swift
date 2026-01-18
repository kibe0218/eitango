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
                    HStack{
                        Spacer()
                        Button(action: {
                            showAlert = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundStyle(vm.customaccentColor)
                        }
                        .padding(.horizontal, 30)
                        .frame(width: geo.size.height * 0.06,  height: geo.size.height * 0.06)
                        .glassEffect(.clear.interactive())
                        .alert("新しい単語帳を作成", isPresented: $showAlert) {
                            TextField("タイトル", text: $title)
                            Button("キャンセル", role: .cancel) {
                                showAlert.toggle()
                            }
                            Button("OK") {
                                guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                Task {
                                    if let id = await vm.addListAPI(userId: vm.userid, title: title){
                                        vm.selectedListId = id
                                    }
                                    vm.noshuffleFlag = true
                                    vm.updateView()
                                    navigateToCardList = true
                                    
                                }
                            }
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                            //trimmingで先頭や末尾にある特定の文字を削除してくれる
                            //isEmptyでから文字列をtrueにしてしまう->disabledでボタンを無効化
                        }
                    }
                    .padding(.horizontal, 30)
                    List{
                        ForEach(vm.Lists, id: \.objectID) { list in
                            HStack {
                                Spacer()
                                VStack{
                                    ZStack{
                                        ForEach(0..<6, id: \.self){ z in
                                            CardListView(z: z, width: geo.size.width, height: geo.size.height)
                                                .environmentObject(vm)
                                        }
                                        Text(list.title ?? "")
                                            .font(.system(size: CGFloat(vm.JpfontSize(i: list.title ?? ""))))
                                            .foregroundStyle(vm.cardfrontColor)
                                            .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.18)
                                            .background(vm.cardColor)
                                            .cornerRadius(20)
                                            .zIndex(100)
                                    }
                                    .onTapGesture{
                                        vm.selectedListId = list.id
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
                            let lists = vm.Lists
                            for index in indices {
                                let list = lists[index]
                                Task {
                                    await vm.deleteListAPI(userId: vm.userid, listId: list.id ?? "")
                                }
                            }
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
            CardsView(path: $path)
                .environmentObject(vm)
                .environmentObject(keyboard)
        }
    }
}

struct CardListView: View {
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    
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
