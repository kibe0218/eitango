import SwiftUI

struct SettingView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: RootViewModel
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Form {
                    Section(header: Text("テーマ").foregroundColor(vm.colorUIState.palette.textColor)) {
                        Picker("テーマ選択", selection: $vm.colorUIState.currentTheme) {
                            Text("シンプルモード").tag(ColorTheme.monochromatic)
                            Text("暖色系").tag(ColorTheme.normal)
                        }
                        .pickerStyle(.menu)
                        .onChange(of: vm.colorUIState.currentTheme) { _, _ in
                            vm.colorUIState.palette = vm.colorUIState.currentTheme.palette(for: colorScheme)
                        }
                    }
                    .listRowBackground(vm.colorUIState.palette.cardColor)
                    Section(header: Text("ユーザー").foregroundColor(vm.colorUIState.palette.textColor)) {
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            Text("ログアウト")
                                .foregroundColor(.red)
                        }
                        .alert("ログアウトしますか？", isPresented: $showLogoutAlert) {
                            Button("キャンセル", role: .cancel) {}
                            Button("ログアウト", role: .destructive) {
                                Task {
                                    try await vm.userActions.logout()
                                }
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
                                Task{
                                    try await vm.userActions.delete()

                                }
                            }
                        }
                    }
                    .listRowBackground(vm.colorUIState.palette.cardColor)
                    Section(header: Text("機能").foregroundColor(vm.colorUIState.palette
                        .textColor)) {
                        Picker(selection: $vm.settingSession.setting.waitTime) {
                            ForEach(1..<10) { second in
                                Text("\(second) 秒").tag(second)
                            }
                        } label: {
                            Text("待機時間")
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: vm.settingSession.setting.waitTime) { _, _ in
                            Task { await vm.playActions.updateView() }
                        }
                    }
                    .listRowBackground(vm.colorUIState.palette.cardColor)
                }
                .scrollContentBackground(.hidden)
                .background(vm.colorUIState.palette.backColor)
            }
        }
        .onChange(of: colorScheme) { _, newValue in
            vm.colorUIState.updateForColorScheme(newValue)
        }
    }
}
