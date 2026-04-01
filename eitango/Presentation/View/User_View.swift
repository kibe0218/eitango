//import SwiftUI
//// import PhotosUI
//
//struct UserView: View {
//    @EnvironmentObject var vm: RootViewModel
//    @Environment(\.colorScheme) var colorScheme
//    
//    @State private var geo_height: CGFloat = 0
//    @State private var geo_width: CGFloat = 0
//    
//    @State private var isActive = false
//    @State private var size = 0.8
//    @State private var selectedImage: UIImage? = nil
//    
//    @State private var navigateToSettings = false
//    
//    var body: some View {
//        GeometryReader { geo in
//            VStack {
//                ZStack {
//                    HStack {
//                        Spacer()
//                        HStack {
//                            Button(action: {
//                                vm.path.append(.setting)
//                            }) {
//                                Image(systemName: "gearshape.2.fill")
//                                    .font(.title)
//                                foregroundStyle(vm.colorUIState.palette.customaccentColor)
//                            }
//                        }
//                        .frame(width: geo_width * 0.25,  height: geo_height * 0.06)
//                        .glassEffect(.clear.interactive())
//                        
//                    }
//                    .padding(.horizontal, 30)
//                }
//                Text(vm.userSession.user?.name ?? "")
//                    .foregroundColor(vm.colorUIState.palette.customaccentColor)
//                    .font(.system(size: geo_height * 0.05))
//                    .bold()
//            }
//            .onAppear {
//                geo_height = geo.size.height
//                geo_width = geo.size.width
//            }
//        }
//        .background(vm.colorUIState.palette.backColor.ignoresSafeArea())
//    }
//}
