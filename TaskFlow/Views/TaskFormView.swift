//
//  TaskFormView.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    let projectId: String
    let memberIds: [String]
    @ObservedObject var taskViewModel: TaskViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .media
    @State private var dueDate = Date().addingTimeInterval(86400 * 3)
    @State private var assigneeId = ""

    var projectMembers: [UserModel] {
        var membersById: [String: UserModel] = [:]

        // 1. Incluir todos los miembros registrados en allUsers que pertenecen al proyecto
        for user in authViewModel.allUsers {
            if let uid = user.id, memberIds.contains(uid) {
                membersById[uid] = user
            }
        }

        // 2. Garantizar que el usuario actual (Líder) esté disponible si pertenece al proyecto
        if let current = authViewModel.currentUser,
           let currentUid = current.id ?? authViewModel.userSession?.uid,
           memberIds.contains(currentUid) {
            var currentWithId = current
            if currentWithId.id == nil {
                currentWithId.id = currentUid
            }
            membersById[currentUid] = currentWithId
        }

        // Ordenar poniendo primero al usuario actual y luego alfabéticamente
        let currentUid = authViewModel.userSession?.uid
        return membersById.values.sorted { first, second in
            if first.id == currentUid { return true }
            if second.id == currentUid { return false }
            return first.name < second.name
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Detalle de la Tarea") {
                    TextField("Título de la tarea", text: $title)
                    TextField("Descripción o criterios", text: $description)
                }

                Section("Planificación") {
                    Picker("Prioridad", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Fecha límite", selection: $dueDate, displayedComponents: .date)
                }

                Section("Asignar Responsable") {
                    Picker("Miembro", selection: $assigneeId) {
                        ForEach(projectMembers, id: \.id) { member in
                            Text("\(member.name) (\(member.role.rawValue))")
                                .tag(member.id ?? "")
                        }
                    }
                }
            }
            .navigationTitle("Nueva Tarea")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let finalAssignee = assigneeId.isEmpty ? (authViewModel.userSession?.uid ?? "") : assigneeId
                        taskViewModel.createTask(
                            title: title,
                            description: description,
                            priority: priority,
                            dueDate: dueDate,
                            projectId: projectId,
                            assigneeId: finalAssignee
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if assigneeId.isEmpty {
                    assigneeId = authViewModel.userSession?.uid ?? (projectMembers.first?.id ?? "")
                }
            }
        }
    }
}
