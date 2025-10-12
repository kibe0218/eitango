import SwiftUI

struct AddCardlist : View{
    var body: some View {
        NavigationStack{
            GeometryReader { geo in
                VStack{
                    ZStack{
                        HStack{
                            Spacer()  // 左側のスペーサーでPickerを中央に寄せる
//                            NavigationLink(destination: AddCard){
//                                Image(systemName: "plus")
//                                    .resizable()
//                                    .frame(width: 20, height: 20)
//                                    .foregroundStyle(Color.accentColor)
//                            }
                        }
                        .padding(.trailing, 50)
                    }
                }
            }
        }
    }
}
