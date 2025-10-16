import SwiftUI

struct EditView: View {
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        GeometryReader { geo in
            VStack{
                ZStack{
                    HStack{
                        Spacer()  // 左側のスペーサーでPickerを中央に寄せる
                        NavigationLink(destination: AddCardlist()){
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.trailing, 50)  // 右だけ10ポイント
                }.frame(height: 70)
                List{
                    ForEach(0..<vm.tangotyou.count, id: \.self) { i in
                        HStack {
                            Spacer()
                            VStack{
                                ZStack{
                                    ForEach(0..<vm.tangotyou.count, id: \.self){ z in
                                        CardListView(i: i, z: z, width: geo.size.width, height: geo.size.height)
                                            .environmentObject(vm)
                                    }
                                    Text(vm.tangotyou[i])
                                        .font(.system(size: CGFloat(vm.JpfontSize(i: vm.tangotyou[i]))))
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .frame(width: geo.size.width * 0.85, height: geo.size.height * 0.18)
                                        .background(Color.gray.opacity(colorScheme == .dark ? 0.6 : 0.2))
                                        .cornerRadius(20)
                                        .zIndex(100)
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
                        vm.tangotyou.remove(atOffsets: indices)
                    }
                    //indicesは削除される要素の位置を示している
                    //atOffsetsで削除＆再描画
                }
                .listStyle(PlainListStyle())
            }
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
                .background(Color.gray.opacity(colorScheme == .dark ? 0.25 : 0.1))
                .cornerRadius(20)
                .offset(y: Double(z) * 5 + 5)
                .scaleEffect(1 - Double(z) * 0.01)
                .zIndex(Double(z))
    }
}
