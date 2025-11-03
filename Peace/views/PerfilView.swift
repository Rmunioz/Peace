//
//  PerfilView.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 14/10/25.
//

import SwiftUI

struct PerfilView: View {
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showEditSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        ProfileImageView(photoURL: authVM.userPhotoURL)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(authVM.userName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(authVM.userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Card con info
                    VStack(spacing: 0) {
                        HStack {
                               // Fila de teléfono
                               profileRow(icon: "phone.fill", title: "Teléfono", value: viewModel.profile.phone)
                               
                               Spacer() // empuja el botón a la derecha
                               
                               // Botón de editar
                               Button {
                                   // Acción para editar teléfono
                                   showEditSheet = true // o la acción que quieras
                               } label: {
                                   Image(systemName: "pencil")
                                       .foregroundColor(.blue)
                               }.padding()
                           }
                        
                        Divider()
                        profileRow(icon: "envelope.fill", title: "Correo", value: authVM.userEmail)
                        Divider()
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                    
                    // Ajustes (ligados al viewmodel directamente)
                    VStack(spacing: 0) {
                        Toggle(isOn: Binding(
                            get: { viewModel.profile.notificationsEnabled },
                            set: { viewModel.profile.notificationsEnabled = $0 }
                        )) {
                            Label("Notificaciones", systemImage: "bell.fill")
                        }
                        .padding()
              
                        Divider()
                        Button {
                            // ejemplo: acción cambiar contraseña
                        } label: {
                            HStack {
                                Label("Cambiar contraseña", systemImage: "key.fill")
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .secondarySystemBackground)))
                    .padding(.horizontal)
                    
                    // Botón cerrar sesión
                    Button(role: .destructive) {
                        authVM.signOut()
                    } label: {
                        Text("Cerrar sesión")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }.padding(.top, 50)
            .sheet(isPresented: $showEditSheet) {
                EditProfileSheet(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Subviews
    
    struct ProfileImageView: View {
        var photoURL: URL?
        
        var body: some View {
            Group {
                if let url = photoURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 84, height: 84)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 84, height: 84)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 84, height: 84)
                                .clipShape(Circle())
                        @unknown default:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 84, height: 84)
                                .clipShape(Circle())
                        }
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 84, height: 84)
                        .clipShape(Circle())
                }
            }
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 4)
        }
    }
    
    @ViewBuilder
    private func profileRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon).frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text(value).font(.body)
            }
            Spacer()
        }
        .padding()
    }
}

// ----------------------------
// MARK: - Edit Sheet (usa copia local y guarda en viewModel)
// ----------------------------
struct EditProfileSheet: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    // copia editable
    @State private var editableProfile: Profile

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        // inicializa el state con el perfil actual
        _editableProfile = State(initialValue: viewModel.profile)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información")) {
                    TextField("Teléfono", text: $editableProfile.phone)
                        .keyboardType(.phonePad)
                    Toggle("Notificaciones", isOn: $editableProfile.notificationsEnabled)
                   
                }
            }
            .navigationTitle("Editar perfil")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        // Validaciones simples (ejemplo)
                        if editableProfile.name.trimmingCharacters(in: .whitespaces).isEmpty {
                            // podrías mostrar un alert; por simplicidad no lo hacemos aquí
                        }
                        viewModel.updateProfile(editableProfile)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}


let mockAuthVM: AuthViewModel = {
    let vm = AuthViewModel()
    vm.loginState = true
    vm.userName = "Rosa Delia"
    vm.userEmail = "rosa@example.com"
    vm.userPhotoURL = URL(string: "https://lh3.googleusercontent.com/example.jpg")
    return vm
}()
// ----------------------------
// MARK: - Previews
// ----------------------------
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PerfilView(viewModel: ProfileViewModel(sample: true))
                .preferredColorScheme(.light)
                .environmentObject(mockAuthVM)
            PerfilView(viewModel: ProfileViewModel(sample: true))
                .preferredColorScheme(.dark)
                .environmentObject(mockAuthVM)
        }
    }
}
