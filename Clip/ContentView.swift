import SwiftUI
import AppKit
import HotKey
import Carbon


struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            
            Button("Close App") {
                showAlert.toggle()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Close App"),
                    message: Text("Are you sure you want to close the app?"),
                    primaryButton: .destructive(Text("Close")) {
                        NSApplication.shared.terminate(self)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
