import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        Group {
            if authVM.loginState {
                MainTabView().environmentObject(authVM)
            } else {
                loginView()
            }
        }
    }
}
