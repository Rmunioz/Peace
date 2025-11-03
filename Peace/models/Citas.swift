//
//  Citas.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 15/10/25.
//


import SwiftUI
// Modelo
struct Citas: Identifiable, Codable {
    let id : Int
    let nombre: String
    let fecha: Date
    let hora: String
    let lugar: String
    var url_img: [String]
}


