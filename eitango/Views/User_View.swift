import SwiftUI
//import PhotosUI

struct UserView: View {
    @EnvironmentObject var vm: PlayViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var geo_height: CGFloat = 0
    @State private var geo_width: CGFloat = 0
    
    @State private var isActive = false
    @State private var size = 0.8
//    @State private var selectedItem: PhotosPickerItem? = nil // 写真への引換券
    @State private var selectedImage: UIImage? = nil
    
    @State private var navigateToSettings = false
    
    var body: some View {
        NavigationStack{
            GeometryReader { geo in
                VStack {
                    ZStack {
                        HStack {
                            Spacer()
                            HStack {
                                Button(action: {
                                    navigateToSettings = true
                                }) {
                                    Image(systemName: "gearshape.2.fill")
                                        .font(.title)
                                        .foregroundStyle(vm.customaccentColor)
                                }
//                                PhotosPicker(
//                                    selection: $selectedItem,
//                                    matching: .images,
//                                    photoLibrary: .shared()
//                                ) {
//                                    Image(systemName: "pencil")
//                                        .font(.title)
//                                        .foregroundStyle(vm.customaccentColor)
//                                }
//                                .onChange(of: selectedItem) { _, newItem in
//                                    Task {
//                                        guard let newItem else { return }
//                                        if let data = try? await newItem.loadTransferable(type: Data.self),
//                                           let uiImage = UIImage(data: data) {
//                                            selectedImage = uiImage
//                                        }
//                                    }
//                                }
                            }
                            .frame(width: geo_width * 0.25,  height: geo_height * 0.06)
                            .glassEffect(.clear.interactive())
                            
                        }
                        .padding(.horizontal, 30)
                    }
//                    HStack{
//                        Spacer()
//                        if let selectedImage {
//                            Image(uiImage: selectedImage)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: geo_width * 0.4, height: geo_width * 0.4)
//                                .clipShape(Circle())
//                                .glassEffect(.clear.interactive())
//                        } else {
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: geo_width * 0.4, height: geo_width * 0.4)
//                                .foregroundStyle(vm.customaccentColor)
//                        }
//                        Spacer()
//                    }
                    Text(vm.userName)
                        .foregroundColor(vm.customaccentColor)
                        .font(.system(size: geo_height * 0.05))
                        .bold()
                }
                .onAppear {
                    geo_height = geo.size.height
                    geo_width = geo.size.width
                }
            }
            .background(vm.backColor.ignoresSafeArea())
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView()
                .environmentObject(vm)
        }
    }
}
