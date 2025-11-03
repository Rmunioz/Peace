import Foundation

class CitasViewModel: ObservableObject {
    @Published var citas: [Citas] = []

    private let baseURL = "http://192.168.100.106/modelsPHP"
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // Verifica disponibilidad en el servidor (y usa comprobación local si ya cargaste citas)
    // completion -> (available: Bool, reason: String?)
    func verificarDisponibilidad(fecha: String, hora: String, completion: @escaping (Bool, String?) -> Void) {
        // Comprobación local rápida (opcional, sólo si self.citas ya está cargado)
        // Evita elegir la misma fecha+hora exactamente
        if !self.citas.isEmpty {
            if self.citas.contains(where: {
                // Comparamos strings: tu modelo guarda fecha como Date, convertimos
                let fechaStr = dateFormatter.string(from: $0.fecha)
                return fechaStr == fecha && $0.hora == hora
            }) {
                completion(false, "Ya existe una cita en esa fecha y hora (comprobación local).")
                return
            }
        }

        // Llamada al endpoint del servidor que valida horario permitido y conflictos
        guard let url = URL(string: "\(baseURL)/verifica-disponibilidad.php") else {
            completion(false, "URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "fecha=\(fecha.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&hora=\(hora.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error verificar disponibilidad (network):", error)
                DispatchQueue.main.async { completion(false, "Error de red") }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(false, "Respuesta vacía del servidor") }
                return
            }

            // Esperamos JSON { available: true/false, reason: "..." }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let available = (json["available"] as? Bool) ?? false
                let reason = json["reason"] as? String
                DispatchQueue.main.async {
                    completion(available, reason)
                }
            } else {
                let resp = String(data: data, encoding: .utf8) ?? "<no body>"
                print("Respuesta inesperada verificarDisponibilidad:", resp)
                DispatchQueue.main.async { completion(false, "Respuesta inválida del servidor") }
            }
        }.resume()
    }

    
    // Agregar cita -> espera que el PHP devuelva JSON con { success: true, id: <nuevoId> }
    // Agregar cita -> primero verifica disponibilidad en servidor
    func agregarCita(nombre: String, fecha: String, hora: String, lugar: String, estatus : String, completion: @escaping (Bool, String?) -> Void) {


        // 2) Verificamos disponibilidad en el servidor
        verificarDisponibilidad(fecha: fecha, hora: hora) { available, reason in
            if !available {
                // no disponible => informar al llamador
                completion(false, reason ?? "No disponible")
                return
            }

            // 3) Si está disponible, procedemos a insertar (igual que antes)
            guard let url = URL(string: "\(self.baseURL)/inserta-cita.php") else {
                completion(false, "URL inválida")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let params = [
                "nombre": nombre,
                "fecha": fecha,
                "hora": hora,
                "lugar": lugar,
                "estatus": estatus
            ]
            let bodyString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                                   .joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error de red al agregar:", error)
                    DispatchQueue.main.async { completion(false, "Error de red al agregar") }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    DispatchQueue.main.async { completion(false, "Respuesta inválida del servidor") }
                    return
                }

                if httpResponse.statusCode != 200 {
                    let resp = String(data: data, encoding: .utf8) ?? ""
                    print("Status code no OK al agregar:", httpResponse.statusCode, resp)
                    DispatchQueue.main.async { completion(false, "Error del servidor al insertar") }
                    return
                }

                // Intentamos parsear JSON { success: true, id: 123 }
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool, success == true,
                   let newId = json["id"] as? Int {

                    let fechaDate = self.dateFormatter.date(from: fecha) ?? Date()
                    let nuevaCita = Citas(id: newId, nombre: nombre, fecha: fechaDate, hora: hora, lugar: lugar, url_img: [])

                    DispatchQueue.main.async {
                        self.citas.append(nuevaCita)
                        completion(true, nil)
                    }
                } else {
                    // servidor no devolvió id, recargamos lista y devolvemos error
                    print("No se recibió id del servidor. Recargando citas...")
                    self.cargarCitas()
                    DispatchQueue.main.async { completion(false, "No se obtuvo id del servidor") }
                }
            }.resume()
        }
    }



    // Cargar todas las citas desde PHP (espera JSON array con id,nombre,fecha,hora,lugar)
    func cargarCitas() {
        guard let url = URL(string: "\(baseURL)/obtener-citas.php") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error al cargar citas:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    var tempCitas: [Citas] = []

                    for json in jsonArray {
                        let id = json["id"] as? Int ?? Int((json["id"] as? String) ?? "") ?? 0
                        let nombre = json["nombre"] as? String ?? ""
                        let fechaStr = json["fecha"] as? String ?? ""
                        let hora = json["hora"] as? String ?? ""
                        let lugar = json["lugar"] as? String ?? ""

                        let fecha = self.dateFormatter.date(from: fechaStr) ?? Date()
                        let cita = Citas(id: id, nombre: nombre, fecha: fecha, hora: hora, lugar: lugar, url_img: [])
                        tempCitas.append(cita)
                    }

                    DispatchQueue.main.async {
                        self.citas = tempCitas
                    }
                } else {
                    print("JSON no es array")
                }
            } catch {
                print("Error parsing JSON:", error)
            }
        }.resume()
    }

    func cargarCitasTerminadas() {
        guard let url = URL(string: "\(baseURL)/obtener-citas-terminadas.php") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error al cargar citas:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    var tempCitas: [Citas] = []

                    for json in jsonArray {
                        let id = json["id"] as? Int ?? Int((json["id"] as? String) ?? "") ?? 0
                        let nombre = json["nombre"] as? String ?? ""
                        let fechaStr = json["fecha"] as? String ?? ""
                        let hora = json["hora"] as? String ?? ""
                        let lugar = json["lugar"] as? String ?? ""

                        let fecha = self.dateFormatter.date(from: fechaStr) ?? Date()
                        let cita = Citas(id: id, nombre: nombre, fecha: fecha, hora: hora, lugar: lugar, url_img: [])
                        tempCitas.append(cita)
                    }

                    DispatchQueue.main.async {
                        self.citas = tempCitas
                    }
                } else {
                    print("JSON no es array")
                }
            } catch {
                print("Error parsing JSON:", error)
            }
        }.resume()
    }

    
    // Eliminar cita -> espera { success: true } del servidor
    // Este método elimina localmente SOLO si el servidor confirma.
    func eliminarCita(id: Int) {
        guard let url = URL(string: "\(baseURL)/eliminar-cita.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = "id=\(id)"
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error al eliminar cita:", error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }

            if let data = data, let respString = String(data: data, encoding: .utf8) {
                print("Respuesta servidor (eliminar):", respString)
            }

            guard httpResponse.statusCode == 200, let data = data else {
                print("Status code no OK al eliminar:", (response as? HTTPURLResponse)?.statusCode ?? -1)
                return
            }

            // Parseamos respuesta del servidor
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool, success == true {
                DispatchQueue.main.async {
                    if let index = self.citas.firstIndex(where: { $0.id == id }) {
                        self.citas.remove(at: index)
                    }
                }
            } else {
                print("Error: el servidor no confirmó la eliminación")
            }
        }.resume()
    }
}
