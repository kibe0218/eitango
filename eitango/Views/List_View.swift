import SwiftUI


struct ListView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAlert = false
    @State private var title: String = ""
    
    var body: some View {
        GeometryReader { geo in
            VStack{
                HStack{
                    Spacer()
                    Button(action: {
                        showAlert = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundStfyle(vm.colorUIState.palette.customaccentColor)
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
                            Task {
                                let list = try await vm.listActions.add(list: AddListRequest(title: title))
                                title = ""
                                vm.moveToCardView(list: list)
                                
                            }
                        }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding(.horizontal, 30)
                List{
                    ForEach(vm.listSession.lists, id: \.id) { list in
                        HStack {
                            Spacer()
                            VStack{
                                ZStack{
                                    ForEach(0..<6, id: \.self){ z in
                                        CardListView(z: z, width: geo.size.width, height: geo.size.height)
                                            .environmentObject(vm)
                                    }
                                    Text(list.title.isEmpty ? "Untitled" : list.title)      .font(.system(size: CGFloat(jpFontSize(list.title))))
                                        .foregroundStyle(vm.colorUIState.palette.cardfrontColor)
                                        .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.18)
                                        .background(vm.colorUIState.palette.cardColor)
                                        .cornerRadius(20)
                                        .zIndex(100)
                                }
                                .onTapGesture{
                                    vm.moveToCardView(list: list)
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
                        let listsToDelete = indices.map { vm.listSession.cards[$0] }
                        Task {
                            for list in listsToDelete {
                                try await vm.listActions.delete(id: list.id)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            Task {
                try await vm.listActions.fetchAll()
            }
        }
        .background(vm.colorUIState.palette.backColor.ignoresSafeArea())
    }
}

struct CardListView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let z: Int
    let width: Double
    let height: Double
        
    var body: some View {
            Text("")
                .frame(width: width * 0.85, height: height * 0.18)
                .background(vm.colorUIState.palette.cardlistmobColor)
                .cornerRadius(20)
                .offset(y: Double(z) * 5 + 5)
                .scaleEffect(1 - Double(z) * 0.01)
                .zIndex(Double(z))
    }
}
