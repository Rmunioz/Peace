//
//  MainTabView.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 15/10/25.
//

import SwiftUI

// Modelo de menú inferior
struct TabItem {
    let icon: String
}

// Vistas de ejemplo para cada pestaña
struct CitasView: View {
    var body: some View {
        VStack {
            CitasListView()
            Spacer()
        }
        .padding()
    }
}

struct CitasTerminadas: View {
    var body: some View {
        VStack {
            CitasTerminadasView()
            Spacer()
        }
        .padding()
    }
}

struct CalendarioView: View {
    var body: some View {
        VStack {
            AgendaView()
            Spacer()
        }
        .padding()
    }
}

struct PerfilTabView: View {
    var body: some View {
        VStack {
            PerfilView()
            Spacer()
        }
        .padding()
    }
}



// Tab bar principal
struct MainTabView: View {
    // Pestaña seleccionada
    @State private var selectedTab = 0
    
    // Items del menú
    private let tabs = [
        TabItem(icon: "clock"),
        TabItem(icon: "checkmark"),
        TabItem(icon: "calendar"),
        TabItem(icon: "person.fill")
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CitasView()
                .tabItem {
                    Image(systemName: tabs[0].icon)
                }
                .tag(0)
            
            CitasTerminadas()
                .tabItem {
                    Image(systemName: tabs[1].icon)
                }
                .tag(1)
            
            CalendarioView()
                .tabItem {
                    Image(systemName: tabs[2].icon)
                }
                .tag(2)
            
            PerfilTabView()
                .tabItem {
                    Image(systemName: tabs[3].icon)
                }
                .tag(3)
        }
        .accentColor(.pink) 
    }
}

// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
