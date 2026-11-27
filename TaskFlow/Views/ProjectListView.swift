//
//  ProjectListView.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var projectViewModel = ProjectViewModel()
    @State private var showingNewProject = false

    var body: some View {
        NavigationStack {
            List {
                if let user = authViewModel.currentUser {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(user.role.rawValue)
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }

                Section("Mis Proyectos (\(projectViewModel.projects.count))") {
                    if projectViewModel.projects.isEmpty {
                        Text("Aún no tienes proyectos. Toca '+' para crear el primero.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(projectViewModel.projects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project, projectViewModel: projectViewModel)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(project.name)
                                        .font(.headline)
                                    Text(project.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    HStack {
                                        Image(systemName: "person.2.fill")
                                        Text("\(project.memberIds.count) miembros")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                projectViewModel.deleteProject(projectViewModel.projects[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("TaskFlow")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Salir") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewProject = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingNewProject) {
                NewProjectSheet(projectViewModel: projectViewModel)
            }
            .onAppear {
                if let uid = authViewModel.userSession?.uid {
                    projectViewModel.listenProjects(for: uid)
                }
            }
        }
    }
}

struct NewProjectSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var projectViewModel: ProjectViewModel

    @State private var name = ""
    @State private var description = ""
    @State private var selectedMembers: Set<String> = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos del Proyecto") {
                    TextField("Nombre del proyecto", text: $name)
                    TextField("Descripción breve", text: $description)
                }

                Section("Miembros del Equipo") {
                    ForEach(authViewModel.allUsers) { user in
                        if let uid = user.id {
                            let isOwner = (uid == authViewModel.userSession?.uid)

                            if isOwner {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(user.name)
                                            .foregroundColor(.primary)
                                        Text("\(user.role.rawValue) • Creador")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            } else {
                                Button {
                                    if selectedMembers.contains(uid) {
                                        selectedMembers.remove(uid)
                                    } else {
                                        selectedMembers.insert(uid)
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(user.name)
                                                .foregroundColor(.primary)
                                            Text(user.role.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if selectedMembers.contains(uid) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nuevo Proyecto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        if let ownerId = authViewModel.userSession?.uid {
                            var finalMembers = selectedMembers
                            finalMembers.insert(ownerId)
                            projectViewModel.createProject(
                                name: name,
                                description: description,
                                ownerId: ownerId,
                                memberIds: Array(finalMembers)
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                if let ownerId = authViewModel.userSession?.uid {
                    selectedMembers.insert(ownerId)
                }
            }
        }
    }
}
