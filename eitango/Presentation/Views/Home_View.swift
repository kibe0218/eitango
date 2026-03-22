import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selection: Int

    
    init() {
        _selection = State(initialValue: 0)
    }
    var body: some View {
        GeometryReader { geo in
            NavigationStack(path: $vm.path) {
                TabView(selection: $selection) {
                    PlayView()
                        .environmentObject(vm)
                        .tabItem {
                            Image(systemName: "play")
                            Text("Play")
                        }
                        .tag(0)
                    ListView()
                        .environmentObject(vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Edit")
                        }
                        .tag(1)
//                    UserView()
//                        .environmentObject(vm)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                        .tabItem {
//                            Image(systemName: "person")
//                            Text("User")
//                        }
//                        .tag(2)
                }
            }
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .card(let list):
                    CardView(list: list)
                case .setting:
                    SettingView()
                }
            }
            .onChange(of: colorScheme) {
                vm.colorUIState.updateForColorScheme(colorScheme)
            }
            .accentColor(vm.colorUIState.palette.customaccentColor)
        }
    }
}
