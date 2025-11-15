import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Form {
                        Section(header: Text("テーマ")) {
                            Picker("色",selection: $vm.colortheme) {
                                Text("シンプル(ダーク/ライトモード対応)").tag(0)
                                Text("暖色").tag(1)
                            }
                            .onChange(of: vm.colortheme){
                                vm.updateView()
                            }
                        }
                        .listRowBackground(vm.cardColor)
                        Section(header: Text("機能")) {
                            Text("待機時間：\(vm.waittime)秒")
                            Picker("", selection: $vm.waittime) {
                                ForEach(1..<10) { second in
                                    Text("\(second) 秒").tag(second)
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
    }
}
