//
//  uploads.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 26/10/25.
//

import Foundation

import UIKit

class UploadService {
    static let shared = UploadService()
    private init() {}
    
    func updateCitaImages(citaId: Int, urls: [String], completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "http://192.168.100.112/modelsPHP/update_cita_images.php") else {
            completion(false, "URL inválida")
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = ["cita_id": citaId, "urls": urls]
        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(false, "Error serializando JSON")
            return
        }

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err {
                completion(false, err.localizedDescription); return
            }
            guard let d = data else { completion(false, "Sin respuesta"); return }
            if let json = try? JSONSerialization.jsonObject(with: d) as? [String: Any],
               let success = json["success"] as? Bool, success == true {
                completion(true, nil)
            } else {
                let s = String(data: d, encoding: .utf8)
                completion(false, s)
            }
        }.resume()
    }


    // multipart upload simple que parsea JSON de respuesta
    func upload(urlString: String, images: [UIImage], parameters: [String: String], completion: @escaping (_ success: Bool, _ filenames: [String]?, _ responseString: String?, _ error: Error?) -> Void) {

        guard let url = URL(string: urlString) else {
            completion(false, nil, nil, NSError(domain: "UploadService", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL inválida"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = createBody(parameters: parameters, images: images, boundary: boundary)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let err = error {
                completion(false, nil, nil, err)
                return
            }

            guard let data = data else {
                completion(false, nil, nil, NSError(domain: "UploadService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sin datos de respuesta"]))
                return
            }

            // intentar parsear JSON {"success":true,"filenames":[...]}
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let success = json["success"] as? Bool ?? false
                var filenames: [String]? = nil
                if let arr = json["filenames"] as? [String] {
                    filenames = arr
                } else if let single = json["filename"] as? String {
                    filenames = [single]
                }
                let respStr = String(data: data, encoding: .utf8)
                completion(success, filenames, respStr, nil)
                return
            }

            // si no es JSON, devolver string (por si tu upload.php devuelve lista separada por comas)
            if let respStr = String(data: data, encoding: .utf8) {
                // intentar separar por comas si parece una lista simple
                let cleaned = respStr.trimmingCharacters(in: .whitespacesAndNewlines)
                if cleaned.contains(",") {
                    let names = cleaned.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    completion(true, names, respStr, nil)
                    return
                } else {
                    // no sabemos; devolver como respuesta en texto
                    completion(false, nil, respStr, nil)
                    return
                }
            }

            completion(false, nil, nil, NSError(domain: "UploadService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Respuesta no interpretada"]))
        }
        task.resume()
    }

    private func createBody(parameters: [String: String], images: [UIImage], boundary: String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        for (key, value) in parameters {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)")
            body.append("\(value)\(lineBreak)")
        }

        for (index, image) in images.enumerated() {
            let filename = "image_\(Int(Date().timeIntervalSince1970))_\(index).jpg"
            let data = image.jpegData(compressionQuality: 0.7) ?? Data()
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"images[]\"; filename=\"\(filename)\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
            body.append(data)
            body.append(lineBreak)
        }

        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}

// helper para Data.append string
private extension Data {
    mutating func append(_ string: String) {
        if let d = string.data(using: .utf8) {
            append(d)
        }
    }
}

