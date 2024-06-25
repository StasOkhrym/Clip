import SwiftUI



struct ContentView: View {
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding();
            Button(
                action: {
                    NSApplication.shared.terminate(nil)
                }
            ) {
            Text("Quit")
            }
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
