import SwiftUI
import PhotosUI

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    var completion: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            parent.completion(image)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.completion(nil)
        }
    }
}



// Vista de cada fila
struct CitaRow: View {
    let cita: Citas

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(cita.nombre)
                .font(.headline)

            HStack {
                Text(cita.fecha, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(cita.hora)
                    .font(.subheadline)
                    .foregroundColor(.pink)
            }

            Text(cita.lugar)
                .font(.subheadline)
                .foregroundColor(.pink)
        }
        .padding()
        .background(Color.gray.opacity(0.03))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// Vista de lista completa
struct CitasListView: View {

    @State private var showAddSheet = false
    @State private var showEvidSheet = false
    @State private var citaSeleccionada: Citas? = nil

    @StateObject var vmCitas = CitasViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if vmCitas.citas.isEmpty {
                    Text("No hay citas")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    List {
                        ForEach(vmCitas.citas) { cita in
                            CitaRow(cita: cita)
                                .listRowSeparator(.hidden)
                                // Swipe derecho: eliminar
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        if let index = vmCitas.citas.firstIndex(where: { $0.id == cita.id }) {
                                            vmCitas.citas.remove(at: index)
                                            vmCitas.eliminarCita(id: cita.id)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }.tint(.pink)
                                }
                                // Swipe izquierdo: abrir sheet de evidencias
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        citaSeleccionada = cita
                                        showEvidSheet = true
                                    } label: {
                                        Image(systemName: "doc.text.image")
                                    }.tint(.green)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Citas pendientes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{
                        showAddSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .onAppear{
                vmCitas.cargarCitas()
            }
            .sheet(isPresented: $showAddSheet) {
                AddCitaSheet(vmAgregarCita: vmCitas)
                    .presentationDetents([.medium])
            }
            .sheet(item: $citaSeleccionada) { cita in
                Evidencias(cita: cita, onFinish: {
                    vmCitas.cargarCitas()
                })
                    .presentationDetents([.medium])
            }
        }
    }
}


// Sheet para agregar cita
struct AddCitaSheet: View {
    @Environment(\.dismiss) var dismiss

    @State private var nombre = ""
    @State private var fecha = Date()
    @State private var hora = Date()
    @State private var lugar = ""
    @State private var estatus = "pendiente"

    @State private var showAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""

    @ObservedObject var vmAgregarCita: CitasViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Llena los campos")) {
                    TextField("Nombre", text: $nombre)
                    DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    DatePicker("Hora", selection: $hora, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                    TextField("Lugar", text: $lugar)
                }

                Section {
                    Button("Guardar") {
                        if nombre.trimmingCharacters(in: .whitespaces).isEmpty ||
                            lugar.trimmingCharacters(in: .whitespaces).isEmpty {
                            showAlert = true
                            return
                        }

                        // Formatear fecha y hora
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let fechaFormateada = dateFormatter.string(from: fecha)

                        let horaFormatter = DateFormatter()
                        horaFormatter.dateFormat = "HH:mm"
                        let horaFormateada = horaFormatter.string(from: hora)

                        vmAgregarCita.agregarCita(nombre: nombre, fecha: fechaFormateada, hora: horaFormateada, lugar: lugar, estatus: estatus) { success, reason in
                            DispatchQueue.main.async {
                                if success {
                                    dismiss()
                                } else {
                                    self.errorMessage = reason ?? "No disponible"
                                    self.showErrorAlert = true
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Agregar Cita")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .alert("Debes llenar los campos obligatorios", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert(errorMessage, isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .accentColor(.pink)
    }
}

// Preview
struct CitasListView_Previews: PreviewProvider {
    static var previews: some View {
        CitasListView()
    }
}
