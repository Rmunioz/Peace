//
//  PeaceApp.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 08/10/25.
//

import SwiftUI

@main
struct PeaceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM) 
        }
    }
}
