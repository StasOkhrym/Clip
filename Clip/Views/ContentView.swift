import SwiftUI


struct ContentView: View {
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            Text("Clip is minimalistic clipoard manager")
                .padding(.top)
                .font(.title3)
            
            VStack{
                Text("To open the window, press ⌘ + ⇧ + V")
                HStack{
                    Text("Navigate through buffer with")
                    Image(systemName: "arrow.left")
                    Image(systemName: "arrow.right")
                }
            }.padding(.bottom, 5)
            
            HStack{
                Button(
                    action: {
                        NSApplication.shared.terminate(nil)
                    }
                ) {
                    Text("Close app")
                }
            }.padding(.bottom)
            
        }.padding(.horizontal)
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
