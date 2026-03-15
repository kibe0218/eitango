import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: RootViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selection: Int

    
    init() {
        _selection = State(initialValue: 0)
    }
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
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
                    UserView()
                        .environmentObject(vm)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {
                            Image(systemName: "person")
                            Text("User")
                        }
                        .tag(2)
//                     DogView()
//                         .environmentObject(vm)
//                         .tabItem {
//                             Image(systemName: "dog")
//                             Text("Dog")
//                         }
//                         .tag(2)
                }
                .accentColor(vm.colorUIState.palette.customaccentColor)
            }
        }
    }
}
