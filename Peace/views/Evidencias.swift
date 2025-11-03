import SwiftUI

// MARK: - Vista Principal
struct Evidencias: View {
    let cita: Citas
    
    var onFinish: (() -> Void)? = nil
    
    @Environment(\.dismiss) var dismiss

    @State private var precio = ""
    @State private var images: [UIImage] = []
    @State private var showCamera = false
    @State private var showAlert = false
    @State private var isUploading = false
    @State private var uploadResultMessage = ""
    @State private var showUploadResult = false

    var body: some View {
        NavigationView {
            Form {
                PrecioSection(precio: $precio)
                ImagenesSection(images: $images, showCamera: $showCamera)
                GuardarButtonSection(isUploading: $isUploading, action: guardarEvidencias)
            }
            .navigationTitle("Evidencias de \(cita.nombre)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .alert("Debes llenar el precio", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert(uploadResultMessage, isPresented: $showUploadResult) {
                Button("OK", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { newImage in
                    if let img = newImage { images.append(img) }
                    showCamera = false
                }
            }
        }
    }

    // MARK: - Función Guardar
    private func guardarEvidencias() {
        guard !precio.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert = true
            return
        }

        if images.isEmpty {
            print("Precio: \(precio), sin imágenes")
            dismiss()
            return
        }

        isUploading = true
        let uploadURL = "http://192.168.100.112/modelsPHP/upload.php"
        let params = [
            "precio": precio,
            "cita_id": "\(cita.id)",
            "cita_nombre": cita.nombre
        ]

        UploadService.shared.upload(urlString: uploadURL, images: images, parameters: params) { success, filenames, responseString, error in
            DispatchQueue.main.async {
                isUploading = false
                if success {
                    uploadResultMessage = "Subida exitosa."
                    images.removeAll()
                    onFinish?()
                    dismiss()
                } else {
                    let errMsg = error?.localizedDescription ?? responseString ?? "Error desconocido"
                    uploadResultMessage = "Error al subir: \(errMsg)"
                    showUploadResult = true
                }
            }
        }
    }
}

// MARK: - Subvista Precio
struct PrecioSection: View {
    @Binding var precio: String

    var body: some View {
        Section(header: Text("Precio total del servicio")) {
            TextField("$", text: $precio)
                .keyboardType(.decimalPad)
        }
    }
}

// MARK: - Subvista Imágenes
struct ImagenesSection: View {
    @Binding var images: [UIImage]
    @Binding var showCamera: Bool

    var body: some View {
        Section(header: Text("Agrega aquí las imágenes del servicio")) {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                        ImagenItemView(image: img, index: idx, images: $images)
                    }

                    Button(action: { showCamera = true }) {
                        VStack {
                            Image(systemName: "plus")
                                .font(.title)
                            Text("Agregar")
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }
}

// MARK: - Subvista Imagen Individual
struct ImagenItemView: View {
    let image: UIImage
    let index: Int
    @Binding var images: [UIImage]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(10)

            Button(action: {
                guard images.indices.contains(index) else { return } // Evitar out-of-bounds
                withAnimation {
                    images.remove(at: index)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            .offset(x: -6, y: 6)
        }
    }
}


// MARK: - Subvista Botón Guardar
struct GuardarButtonSection: View {
    @Binding var isUploading: Bool
    let action: () -> Void

    var body: some View {
        Section {
            Button(action: action) {
                if isUploading {
                    HStack {
                        ProgressView()
                        Text(" Subiendo...")
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Text("Guardar")
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(isUploading)
            .accentColor(.pink)
        }
    }
}
