import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var selection = 0
    @StateObject var keyboard = KeyboardObserver()

    
    
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
                    EditView()
                        .environmentObject(vm)
                        .environmentObject(keyboard)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {
                            Image(systemName: "pencil.and.ellipsis.rectangle")
                            Text("Edit")
                        }
                        .tag(1)
                    UserView()
                        .environmentObject(vm)
                        .environmentObject(keyboard)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .tabItem {
                            Image(systemName: "person")
                            Text("User")
                        }
                        .tag(2)
//                    DogView()
//                        .environmentObject(vm)
//                        .tabItem {
//                            Image(systemName: "dog")
//                            Text("Dog")
//                        }
//                        .tag(2)
                }
                .accentColor(vm.customaccentColor)
                .onChange(of: selection) {vm.updateView()}
                .onAppear{
                    vm.updateView()
                    vm.colorS = colorScheme
                }
            }
        }
    }
}
