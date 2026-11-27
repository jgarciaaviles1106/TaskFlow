//
//  ProjectDetailView.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: ProjectModel
    @ObservedObject var projectViewModel: ProjectViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()

    @State private var showingNewTask = false
    @State private var showingAddMember = false

    var completedCount: Int {
        taskViewModel.tasks.filter { $0.status == .completada }.count
    }

    var body: some View {
        List {
            Section("Resumen del Proyecto") {
                Text(project.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Label("\(completedCount)/\(taskViewModel.tasks.count) completadas", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    Spacer()
                    Button("Equipo (\(project.memberIds.count))") {
                        showingAddMember = true
                    }
                    .font(.caption.bold())
                    .buttonStyle(.bordered)
                }
            }

            Section("Filtrar por Estado") {
                Picker("Estado", selection: $taskViewModel.selectedStatusFilter) {
                    Text("Todas").tag(TaskStatus?.none)
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(TaskStatus?.some(status))
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Tareas (\(taskViewModel.filteredTasks.count))") {
                if taskViewModel.filteredTasks.isEmpty {
                    Text("No hay tareas en esta vista.")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(taskViewModel.filteredTasks) { task in
                        TaskRowView(
                            task: task,
                            assigneeName: userName(for: task.assigneeId),
                            taskViewModel: taskViewModel
                        )
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            taskViewModel.deleteTask(taskViewModel.filteredTasks[index])
                        }
                    }
                }
            }
        }
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingNewTask = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewTask) {
            if let projectId = project.id {
                TaskFormView(projectId: projectId, memberIds: project.memberIds, taskViewModel: taskViewModel)
            }
        }
        .sheet(isPresented: $showingAddMember) {
            AddMemberSheet(project: project, projectViewModel: projectViewModel)
        }
        .onAppear {
            if let projectId = project.id {
                taskViewModel.listenTasks(for: projectId)
            }
        }
    }

    private func userName(for uid: String) -> String {
        let currentUid = authViewModel.currentUser?.id ?? authViewModel.userSession?.uid
        if uid == currentUid, let currentName = authViewModel.currentUser?.name {
            return currentName
        }
        return authViewModel.allUsers.first(where: { $0.id == uid })?.name ?? "Sin asignar"
    }
}

struct TaskRowView: View {
    let task: TaskModel
    let assigneeName: String
    @ObservedObject var taskViewModel: TaskViewModel

    var priorityColor: Color {
        switch task.priority {
        case .alta: return .red
        case .media: return .orange
        case .baja: return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.status == .completada)
                Spacer()
                Text(task.priority.rawValue)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(priorityColor.opacity(0.15))
                    .foregroundColor(priorityColor)
                    .cornerRadius(6)
            }

            if !task.description.isEmpty {
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Label(assigneeName, systemImage: "person.fill")
                Spacer()
                Label(task.dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
            }
            .font(.caption2)
            .foregroundColor(.secondary)

            Menu {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Button(status.rawValue) {
                        taskViewModel.updateTaskStatus(task, newStatus: status)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Estado: \(task.status.rawValue)")
                    Image(systemName: "chevron.down")
                }
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.systemGray6))
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddMemberSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    let project: ProjectModel
    @ObservedObject var projectViewModel: ProjectViewModel

    private var teamCandidates: [UserModel] {
        var usersById: [String: UserModel] = [:]
        for user in authViewModel.allUsers {
            if let uid = user.id {
                usersById[uid] = user
            }
        }
        if let current = authViewModel.currentUser,
           let currentUid = current.id ?? authViewModel.userSession?.uid {
            var currentWithId = current
            if currentWithId.id == nil {
                currentWithId.id = currentUid
            }
            usersById[currentUid] = currentWithId
        }
        let currentUid = authViewModel.userSession?.uid
        return usersById.values.sorted { first, second in
            if first.id == currentUid { return true }
            if second.id == currentUid { return false }
            return first.name < second.name
        }
    }

    var body: some View {
        NavigationStack {
            List(teamCandidates, id: \.id) { user in
                if let uid = user.id {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(user.name)
                            Text(user.role.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if project.memberIds.contains(uid) {
                            Text("Miembro")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Button("Agregar") {
                                if let projectId = project.id {
                                    projectViewModel.addMember(to: projectId, userId: uid)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
            }
            .navigationTitle("Equipo del Proyecto")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
    }
}
