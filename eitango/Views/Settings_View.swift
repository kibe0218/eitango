import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Form {
                        Section(header: Text("テーマ").foregroundColor(vm.textColor)) {
                            Toggle(isOn: Binding<Bool>(
                                get: { vm.colortheme == 0 },
                                set: { newValue in
                                    vm.colortheme = newValue ? 0 : 1
                                    vm.updateView()
                                }
                            )) {
                                Text("シンプルモード")
                                    .foregroundColor(vm.textColor)
                            }
                        }
                        .listRowBackground(vm.cardColor)
                        Section(header: Text("ユーザー").foregroundColor(vm.textColor)) {
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                Text("ログアウト")
                                    .foregroundColor(.red)
                            }
                            .alert("ログアウトしますか？", isPresented: $showLogoutAlert) {
                                Button("キャンセル", role: .cancel) {}
                                Button("ログアウト", role: .destructive) {
                                    vm.logoutUserAuth()
                                }
                            }
                            Button(action: {
                                showDeleteAlert = true
                            }) {
                                Text("ユーザー削除")
                                    .foregroundColor(.red)
                            }
                            .alert("本当にユーザー削除しますか？", isPresented: $showDeleteAlert) {
                                Button("キャンセル", role: .cancel) {}
                                Button("削除", role: .destructive) {
                                    vm.deleteUserFrow()
                                }
                            }
                        }
                        .listRowBackground(vm.cardColor)
                        Section(header: Text("機能").foregroundColor(vm.textColor)) {
                            Text("待機時間：\(vm.waittime)秒").foregroundColor(vm.textColor)
                            Picker("", selection: $vm.waittime) {
                                ForEach(1..<10) { second in
                                    Text("\(second) 秒").tag(second).foregroundColor(vm.textColor)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .onChange(of: vm.waittime){
                                vm.updateView()
                            }
                        }
                        .listRowBackground(vm.cardColor)
                    }
                    .scrollContentBackground(.hidden)
                    .background(vm.backColor)
                }
            }
        }
        .onReceive(vm.$authState) { state in
            switch state {
            case .success(.logoutUserAuth):
                print("🟡 authState set:", vm.authState)
                vm.backToDefaultCoreData()
                vm.reinit()
                vm.moveToStartView()
            default:
                break
            }
        }
        .onReceive(vm.$userState) { state in
            switch state {
            case .failed:
                break
            case .success(.deleteUserAPI):                vm.backToDefaultCoreData()
                vm.reinit()
                vm.moveToStartView()
            default:
                break
            }
        }
    }
}
