//
//  EvidenciasViewModel.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 27/10/25.
//

// MARK: - Ejemplo de integración: subir imágenes y actualizar BD
import UIKit

class EvidenciasViewModel {
    static let shared = EvidenciasViewModel()
    private init() {}

    /// Sube imágenes y actualiza la columna url_img de la cita con las URLs resultantes
    func subirImagenesYGuardarEnBD(citaId: Int, images: [UIImage], completion: @escaping (Bool, String?) -> Void) {
        guard !images.isEmpty else {
            completion(false, "No hay imágenes para subir")
            return
        }

        // URL de tu upload.php
        let uploadURL = "http://192.168.100.106/modelsPHP/upload.php"
        // Si tus imágenes se sirven desde uploads/ en el servidor
        let baseURLUploads = "http://192.168.100.106/modelsPHP/uploads/"

        // parámetros opcionales que necesite tu upload.php
        let params: [String: String] = ["cita_id": "\(citaId)"]

        UploadService.shared.upload(urlString: uploadURL, images: images, parameters: params) { success, filenames, respStr, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "Error upload: \(error.localizedDescription)")
                    return
                }

                guard success, let filenames = filenames, !filenames.isEmpty else {
                    // Si upload.php devuelve texto con nombres separados por coma, tu UploadService ya intenta parsear.
                    completion(false, "No se recibieron filenames. Resp: \(respStr ?? "sin respuesta")")
                    return
                }

                // Construir URLs completas (o enviar solo filenames según cómo quieras guardar)
                let urls = filenames.map { baseURLUploads + $0 }

                // Llamar al endpoint que actualiza la BD
                UploadService.shared.updateCitaImages(citaId: citaId, urls: urls) { updated, msg in
                    DispatchQueue.main.async {
                        if updated {
                            completion(true, nil)
                        } else {
                            completion(false, "Error actualizando BD: \(msg ?? "desconocido")")
                        }
                    }
                }
            }
        }
    }
}

