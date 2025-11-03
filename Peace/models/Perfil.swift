//
//  Perfil.swift
//  Peace
//
//  Created by Rosa delia Correa muñoz on 20/10/25.
//

import SwiftUI
import Combine

// ----------------------------
// MARK: - Model
// ----------------------------
struct Profile: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var email: String
    var phone: String
    //var company: String
    var avatarURL: String? = nil // opcional, si quieres usar AsyncImage
    var notificationsEnabled: Bool = true
    //var isPrivate: Bool = false
}
