//
//  CitaNueva.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 15/10/25.
//
import SwiftUI

struct CitasAgenda: Identifiable {
    let id = UUID()
    let tittle: String
    let hora: String
    let lugar: String
    let fecha: Date
}

// Datos de ejemplo
let todasLasCitas = [
    CitasAgenda(tittle: "Cita 1", hora: "12:00", lugar: "Sucursal Coacalco", fecha: Date()),
    CitasAgenda(tittle: "Cita 2", hora: "14:00", lugar: "Sucursal Satélite", fecha: Date().addingTimeInterval(86400)), // +1 día
    CitasAgenda(tittle: "Cita 3", hora: "16:00", lugar: "Sucursal Centro", fecha: Date())
]
