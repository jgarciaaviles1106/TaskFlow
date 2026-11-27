//
//  TaskViewModel.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var selectedStatusFilter: TaskStatus? = nil
    @Published var selectedAssigneeFilter: String? = nil
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    var filteredTasks: [TaskModel] {
        tasks.filter { task in
            let matchesStatus = selectedStatusFilter == nil || task.status == selectedStatusFilter
            let matchesAssignee = selectedAssigneeFilter == nil || task.assigneeId == selectedAssigneeFilter
            return matchesStatus && matchesAssignee
        }
    }

    func listenTasks(for projectId: String) {
        listener?.remove()
        listener = db.collection("tasks")
            .whereField("projectId", isEqualTo: projectId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = error.localizedDescription
                    }
                    return
                }
                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self?.tasks = documents.compactMap { try? $0.data(as: TaskModel.self) }
                        .sorted { $0.dueDate < $1.dueDate }
                }
            }
    }

    func createTask(
        title: String,
        description: String,
        priority: TaskPriority,
        dueDate: Date,
        status: TaskStatus = .porHacer,
        projectId: String,
        assigneeId: String
    ) {
        let task = TaskModel(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate,
            status: status,
            projectId: projectId,
            assigneeId: assigneeId
        )

        do {
            _ = try db.collection("tasks").addDocument(from: task)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func updateTaskStatus(_ task: TaskModel, newStatus: TaskStatus) {
        guard let taskId = task.id else { return }
        db.collection("tasks").document(taskId).updateData([
            "status": newStatus.rawValue
        ]) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func updateTask(_ task: TaskModel) {
        guard let taskId = task.id else { return }
        do {
            try db.collection("tasks").document(taskId).setData(from: task)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func deleteTask(_ task: TaskModel) {
        guard let taskId = task.id else { return }
        db.collection("tasks").document(taskId).delete { [weak self] error in
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
