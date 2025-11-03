import SwiftUI

struct AgendaView: View {
    @State private var fechaSeleccionada = Date()
    
    @StateObject var vmCitas = CitasViewModel()
    
    // Filtra citas para la fecha seleccionada
    var citasDelDia: [Citas] {
        let calendar = Calendar.current
        return vmCitas.citas.filter { calendar.isDate($0.fecha, inSameDayAs: fechaSeleccionada) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Calendario (DatePicker estilo gráfico)
                DatePicker(
                    "Selecciona fecha",
                    selection: $fechaSeleccionada,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                // Lista de citas del día seleccionado
                if citasDelDia.isEmpty {
                    Spacer()
                    Text("No hay citas para esta fecha")
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                } else {
                    List(citasDelDia) { cita in
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
                        .background(.gray.opacity(0.03))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding()
            .navigationTitle("Agenda")
            .onAppear {
                vmCitas.cargarCitas() // Trae las citas desde el ViewModel
            }
        }
        .accentColor(.pink)
    }
}

// Preview
struct CalendarioView_Previews: PreviewProvider {
    static var previews: some View {
        AgendaView()
    }
}
