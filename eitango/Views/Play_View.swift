import SwiftUI

struct PlayView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    
    @State var title: String = ""

    var body: some View {
        GeometryReader { geo in
            ZStack{
                VStack {
                    ZStack {
                        HStack {
                            Button(action: {
                                vm.shuffleFlag.toggle()
                                vm.updateView()
                            }) {
                                Image(systemName: "shuffle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(vm.shuffleFlag ? vm.customaccentColor : vm.noaccentColor)
                            }
                            .padding(EdgeInsets(top: 0,leading: 40, bottom: 0, trailing: 10))
                            Button(action: {
                                vm.repeatFlag.toggle()
                            }) {
                                Image(systemName: "repeat")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(vm.repeatFlag ? vm.customaccentColor : vm.noaccentColor)
                            }
                            Spacer()
                        }
                        HStack {
                            Spacer() // 左側のスペーサーでPickerを中央に寄せる
                            Picker("単語帳", selection: $vm.number) {
                                ForEach(0..<vm.tangotyou.count, id: \.self) { index in
                                    Text(vm.tangotyou[index]).tag(index)
                                }
                            }
                            .tint(vm.toggleColor)
                            Spacer()
                        }
                        .padding(20)
                        
                        HStack {
                            Spacer() // 左側のスペーサーでPickerを中央に寄せる
                            Toggle("", isOn: $vm.reverse)
                                .tint(vm.customaccentColor)
                        }
                        .padding(30)
                        .onChange(of: vm.reverse) {
                            vm.updateView()
                        }
                    }
                    .frame(height: 70)
                    ForEach(0..<min(vm.Enlist.count, vm.Jplist.count, 4), id: \.self) { i in
                        CardItemView(i: i,width: geo.size.width, height: geo.size.height)
                            .environmentObject(vm)
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                VStack {
                    Spacer()
                    if vm.showToast {
                        VStack {
                            Text("追加しました👍")
                                .frame(width: 200,height: 25)
                                .padding()
                                .background(vm.customaccentColor.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .zIndex(1)
                            Spacer()
                        }
                        .padding()
                    }
                    Spacer()
                }
            
            }
        }
        .onAppear{
            vm.colorS = colorScheme
        }
        .onChange(of: vm.number) {
            vm.numberFlag = true
            vm.updateView()
        }
        .onChange(of: vm.reverse) {vm.updateView()}
        .onChange(of: vm.showNotification) {
            if vm.showNotification {
                withAnimation {
                    vm.showToast = true
                }
                // 2秒後に非表示＋vm側をリセット
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    //メイン処理
                    withAnimation {
                        vm.showToast = false
                        vm.showNotification = false
                    }
                }
            }
        }
        .background(vm.backColor.ignoresSafeArea())
    }
}

struct CardItemView: View{
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let i: Int
    let width: Double
    let height: Double
    
    var body: some View {
        ZStack {
            Text(vm.Enlist[i])
                .font(.system(size: vm.Finishlist[i] ? CGFloat(vm.JpfontSize(i: vm.Enlist[i])) : CGFloat(vm.EnfontSize(i: vm.Enlist[i]))))
                .foregroundStyle(
                    vm.EnColor(y: vm.isFlipped[i], rev: vm.reverse, colorScheme: colorScheme)
                )
                .frame(width: width * 0.85,height: height * 0.18)
                .background(vm.cardColor)
                .cornerRadius(20)
                .opacity(vm.Enopacity(y: vm.isFlipped[i], rev: vm.reverse))
                .scaleEffect(x: vm.reverse ? -1 : 1, y: 1)
            Text(vm.Jplist[i])
                .font(.system(size: CGFloat(vm.JpfontSize(i: vm.Jplist[i]))))
                .foregroundStyle(
                    vm.JpColor(y: vm.isFlipped[i], rev: vm.reverse, colorScheme: colorScheme)
                )
                .frame(width: width * 0.85, height: height * 0.18)
                .background(vm.cardColor)
                .cornerRadius(20)
                .opacity(vm.Jpopacity(y: vm.isFlipped[i], rev: vm.reverse))
                .scaleEffect(x: vm.reverse ? 1 : -1, y: 1)
        }
        .padding(.bottom,10)
        .rotation3DEffect(
            .degrees(vm.isFlipped[i] ? -180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeOut(duration: 0.4), value: vm.isFlipped[i])
        .onTapGesture {
            if !vm.Finishlist[i]{
                vm.FlippTask(i: i)
            }
        }
        .onTapGesture(count: 2) {
            if vm.isFlipped[i] {
                vm.MistakeTask(i: i)
            }
        }
    }
}
