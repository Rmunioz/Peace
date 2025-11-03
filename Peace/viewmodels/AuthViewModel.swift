import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import UIKit

// MARK: - Extensión para obtener el top view controller en SwiftUI
extension UIApplication {
    static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first { $0.isKeyWindow }?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

class AuthViewModel: ObservableObject {
    // datos para login
    @Published var loginState = false
    @Published var lastErrorMessage: String?
    
    
    
    // Datos del usuario
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhotoURL: URL?
    
    init() {
        // Si ya hay un usuario en Firebase al iniciar, marca loginState
        
        if let currentUser = Auth.auth().currentUser {
            loginState = true
            loadUserData(from: currentUser)
        }
    }

    // MARK: - Iniciar sesión con Google
    func signIn() {
        guard let rootVC = UIApplication.topViewController() else {
            lastErrorMessage = "No se pudo obtener ViewController para presentar Sign In"
            return
        }
        
        // Usando nueva API de Google SignIn
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            if let error = error {
                self?.lastErrorMessage = error.localizedDescription
                print("Error de Google SignIn: \(error.localizedDescription)")
                return
            }
            self?.authenticateWithFirebase(user: result?.user)
        }
    }
    
    // MARK: - Autenticación con Firebase
    private func authenticateWithFirebase(user: GIDGoogleUser?) {
        guard let user = user else {
            lastErrorMessage = "Usuario de Google no disponible"
            return
        }
        
        guard let idToken = user.idToken?.tokenString else {
            lastErrorMessage = "No se pudo obtener el ID Token"
            return
        }
        
        let accessToken = user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
                self?.lastErrorMessage = error.localizedDescription
                print("Error autenticando con Firebase: \(error.localizedDescription)")
                return
            }
            
            print("Inicio de sesión exitoso con usuario: \(authResult?.user.email ?? "desconocido")")
            self?.loginState = true
        }
    }
    
    
    // MARK: - Cargar datos del usuario
    private func loadUserData(from user: User) {
        self.userName = user.displayName ?? "Usuario"
        self.userEmail = user.email ?? "Sin correo"
        self.userPhotoURL = user.photoURL
    }
    
    
    // MARK: - Cerrar sesión
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            loginState = false
        } catch {
            lastErrorMessage = error.localizedDescription
            print("Error al cerrar sesión: \(error.localizedDescription)")
        }
    }
}
