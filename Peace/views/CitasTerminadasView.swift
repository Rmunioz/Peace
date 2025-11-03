//
//  CitasTerminadasView.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 27/10/25.
//

import SwiftUI

// Vista de lista completa
struct CitasTerminadasView: View {

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
            .navigationTitle("Citas terminadas")
            .onAppear{
                vmCitas.cargarCitasTerminadas()
            }
            .sheet(isPresented: $showAddSheet) {
                AddCitaSheet(vmAgregarCita: vmCitas)
                    .presentationDetents([.medium])
            }
            .sheet(item: $citaSeleccionada) { cita in
                Evidencias(cita: cita)
                    .presentationDetents([.medium])
            }
        }
    }
}


#Preview {
    CitasTerminadasView()
}
