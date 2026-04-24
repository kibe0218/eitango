import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: RootViewModel
    @EnvironmentObject var colorUIState: ColorUIState
    @Environment(\.colorScheme) var colorScheme
    @State private var selection: Int

    
    init() {
        _selection = State(initialValue: 0)
    }
    var body: some View {
        GeometryReader { geo in
            NavigationStack(path: $vm.homePath) {
                TabView(selection: $selection) {
                    PlayView()
                        .tabItem {
                            Image(systemName: "play")
                            Text("Play")
                        }
                        .tag(0)
                    ListView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Edit")
                        }
                        .tag(1)
//                    UserView()
//                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                        .tabItem {
//                            Image(systemName: "person")
//                            Text("User")
//                        }
//                        .tag(2)
                }
            }
            .navigationDestination(for: HomeScreen.self) { screen in
                switch screen {
                case .card(let list):
                    CardView(list: list)
                case .setting:
                    SettingView()
                }
            }
            .onChange(of: colorScheme) {
                colorUIState.updateForColorScheme(colorScheme)
            }
            .accentColor(colorUIState.palette.customaccentColor)
        }
    }
}
