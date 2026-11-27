//
//  UserModel.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import Foundation
import FirebaseFirestoreSwift

enum UserRole: String, CaseIterable, Codable {
    case lider = "Líder"
    case desarrollador = "Desarrollador"
    case disenador = "Diseñador"
    case qa = "QA"
}

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var role: UserRole
}

