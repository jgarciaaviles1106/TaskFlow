//
//  TaskModel.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import Foundation
import FirebaseFirestoreSwift

enum TaskPriority: String, CaseIterable, Codable {
    case baja = "Baja"
    case media = "Media"
    case alta = "Alta"
}

enum TaskStatus: String, CaseIterable, Codable {
    case porHacer = "Por hacer"
    case enProgreso = "En progreso"
    case completada = "Completada"
}

struct TaskModel: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var priority: TaskPriority
    var dueDate: Date
    var status: TaskStatus
    var projectId: String
    var assigneeId: String
}
