//
//  loginView.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 14/10/25.
//

import SwiftUI

struct loginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
                    Text("Bienvenido...")
                        .font(.headline)
                    
                    Button("Sign in with Google") {
                        authVM.signIn()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .alert(item: $authVM.lastErrorMessage) { error in
                    Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
                }
    }
}


// Para que .alert(item:) funcione con String
extension String: @retroactive Identifiable {
    public var id: String { self }
}

#Preview {
    loginView()
}
