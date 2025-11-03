//
//  PerfilViewModel.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 20/10/25.
//
import SwiftUI
import Combine
// ----------------------------
// MARK: - ViewModel
// ----------------------------
final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile

    // Inicializador con datos estáticos por defecto
    init(sample: Bool = true) {
        if sample {
            self.profile = Profile(
                name: "Usuario desconocido",
                email: "usuario@example.com",
                phone: "+52 55 1234 5678",
                //company: "",
                // Puedes poner una URL válida si quieres probar AsyncImage.
                avatarURL: nil,
                notificationsEnabled: true
                //isPrivate: false
            )
        } else {
            self.profile = Profile(name: "", email: "", phone: "")
        }
    }

    // Actualiza todo el perfil (por ejemplo desde el sheet)
    func updateProfile(_ newProfile: Profile) {
        // aquí podrías añadir validaciones, persistencia, llamada a API, etc.
        profile = newProfile
    }

    // Función ejemplo para cerrar sesión
    func signOut() {
        // Lógica real de cierre de sesión aquí.
        // Por ahora, la dejamos como ejemplo: limpiar datos
        
    }

    // Función para toggles rápidos
    func toggleNotifications() {
        profile.notificationsEnabled.toggle()
    }
    func togglePrivate() {
        //profile.isPrivate.toggle()
    }
}
