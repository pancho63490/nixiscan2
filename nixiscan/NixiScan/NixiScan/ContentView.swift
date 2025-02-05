import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = false

    var body: some View {
        Group {
            if isLoggedIn {
                OrderListView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
