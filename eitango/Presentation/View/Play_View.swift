import SwiftUI

struct PlayView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: RootViewModel
    
    @State var showNotification: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack{
                VStack {
                    PlayHeaderView()
                    ForEach(Array(vm.playActions.playUI.screenSlots.enumerated()), id: \.offset) { position, _ in
                        PlayCardView(
                            showNotification: $showNotification,
                            position: position,
                            width: geo.size.width,
                            height: geo.size.height
                        )
                    }
                    .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                VStack {
                    Spacer()
                    if showNotification {
                        VStack {
                            Text("追加しました👍")
                                .frame(width: 200,height: 25)
                                .padding()
                                .background(vm.colorUIState.palette.customaccentColor.opacity(0.5))
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
        .task {
            await vm.playActions.updateView()
        }
        .task(id: vm.playActions.playSession.selectedListId) {
            await vm.playActions.updateView()
        }
        .task(id: vm.playActions.playSession.reverse) {
            await vm.playActions.updateView()
        }
        .background(vm.colorUIState.palette.backColor.ignoresSafeArea())
    }
}

struct PlayHeaderView: View {
    @EnvironmentObject var vm: RootViewModel

    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    vm.playActions.playSession.mode.toggle()
                    Task {
                        await vm.playActions.updateView()
                    }
                    
                }) {
                    Image(systemName: "shuffle")
                        .font(.title)
                        .foregroundStyle(
                            vm.playActions.playSession.mode == .ordered
                            ? vm.colorUIState.palette.customaccentColor
                            : vm.colorUIState.palette.noaccentColor
                        )
                }
                .padding(.leading, 40)
                Button(action: {
                    vm.playActions.playSession.looping.toggle()
                }) {
                    Image(systemName: "repeat")
                        .font(.title)
                        .foregroundStyle(vm.playActions.playSession.looping ? vm.colorUIState.palette.customaccentColor : vm.colorUIState.palette.noaccentColor)
                }
                Spacer()
            }
            HStack {
                Spacer()
                if !vm.listSession.lists.isEmpty {
                    Picker("単語帳", selection: $vm.playActions.playSession.selectedListId) {
                        ForEach(vm.listSession.lists) { list in
                            Text(list.title)
                                .tag(list.id)
                        }
                    }
                }
                Spacer()
            }
            .padding(20)

            HStack {
                Spacer()
                Toggle("", isOn: $vm.playActions.playSession.reverse)
                    .tint(vm.colorUIState.palette.customaccentColor)
            }
            .padding(30)
        }
        .frame(height: 70)
    }
}

struct PlayCardView: View{
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var showNotification: Bool
    
    let position: Int
    let width: Double
    let height: Double
    
    var body: some View {
        if let screenCard = vm.playActions.playUI.screenSlots[position] {
            ZStack {
                switch screenCard.cardSide {
                case .front:
                    Text(screenCard.card.en)
                        .font(.system(size: CGFloat(enFontSize(screenCard.card.en))))
                        .foregroundStyle(
                            vm.playActions.currentCardColor(
                                position: position,
                                colorScheme: colorScheme
                            )
                        )
                        .frame(width: width * 0.85, height: height * 0.18)
                        .background(vm.colorUIState.palette.cardColor)
                        .cornerRadius(20)
                case .back:
                    Text(screenCard.card.jp)
                        .font(.system(size: CGFloat(jpFontSize(screenCard.card.en))))
                        .foregroundStyle(
                            vm.playActions.currentCardColor(
                                position: position,
                                colorScheme: colorScheme
                            )
                        )
                        .frame(width: width * 0.85, height: height * 0.18)
                        .background(vm.colorUIState.palette.cardColor)
                        .cornerRadius(20)
                }
            }
            .rotation3DEffect(
                .degrees(screenCard.cardSide == .back ? -180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(
                .easeOut(duration: 0.4),
                value: screenCard.cardSide
            )
            .onTapGesture {
                vm.playActions.flipTask(
                    slotIndex: position
                )
            }
            .onTapGesture(count: 2) {
                if screenCard.cardSide == .back {
                    Task {
                        withAnimation {
                            showNotification = true
                        }
                        await vm.playActions.mistakeTask(slotIndex: position)
                        await DelayController.wait(seconds: 2)
                            showNotification = false
                    }
                }
            }
        } else {
            Text("finished")
                .font(.system(size: CGFloat(enFontSize("finished"))))
                .foregroundStyle(
                    vm.playActions.currentCardColor(
                        position: position,
                        colorScheme: colorScheme
                    )
                )
                .frame(width: width * 0.85, height: height * 0.18)
                .background(vm.colorUIState.palette.cardColor)
                .cornerRadius(20)
        }
    }
}


