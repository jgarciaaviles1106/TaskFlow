//
//  ProjectViewModel.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProjectViewModel: ObservableObject {
    @Published var projects: [ProjectModel] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func listenProjects(for userId: String) {
        listener?.remove()
        listener = db.collection("projects")
            .whereField("memberIds", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = error.localizedDescription
                    }
                    return
                }
                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self?.projects = documents.compactMap { try? $0.data(as: ProjectModel.self) }
                }
            }
    }

    func createProject(name: String, description: String, ownerId: String, memberIds: [String]) {
        var uniqueMembers = Set(memberIds)
        uniqueMembers.insert(ownerId)

        let project = ProjectModel(
            name: name,
            description: description,
            ownerId: ownerId,
            memberIds: Array(uniqueMembers)
        )

        do {
            _ = try db.collection("projects").addDocument(from: project)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func addMember(to projectId: String, userId: String) {
        db.collection("projects").document(projectId).updateData([
            "memberIds": FieldValue.arrayUnion([userId])
        ]) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func deleteProject(_ project: ProjectModel) {
        guard let projectId = project.id else { return }
        db.collection("projects").document(projectId).delete { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
