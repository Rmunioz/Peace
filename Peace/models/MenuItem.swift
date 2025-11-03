//
//  menuModel.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 14/10/25.
//

import SwiftUI

struct MenuItem:Identifiable{
    let id = UUID()
    let tittle : String
    let icon: String
}

let menuItems = [
    MenuItem(tittle: "Inicio", icon: "house.fill"),
    MenuItem(tittle: "Perfil", icon: "person.fill"),
    MenuItem(tittle: "Configuración", icon: "gearshape.fill")
]
