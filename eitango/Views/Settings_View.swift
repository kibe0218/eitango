import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: PlayViewModel
    
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
    }
}
