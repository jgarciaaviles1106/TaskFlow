//
//  AuthViewModel.swift
//  TaskFlow
//
//  Creado por Julio Garcìa en 25/11/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserModel?
    @Published var allUsers: [UserModel] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let db = Firestore.firestore()

    init() {
        self.userSession = Auth.auth().currentUser
        if userSession != nil {
            fetchCurrentUser()
            fetchAllUsers()
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.userSession = result?.user
                self?.fetchCurrentUser()
                self?.fetchAllUsers()
            }
        }
    }

    func register(name: String, email: String, password: String, role: UserRole) {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
                return
            }

            guard let uid = result?.user.uid else { return }
            let newUser = UserModel(id: uid, name: name, email: email, role: role)

            do {
                try self?.db.collection("users").document(uid).setData(from: newUser) { error in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if let error = error {
                            self?.errorMessage = error.localizedDescription
                            return
                        }
                        self?.userSession = result?.user
                        self?.currentUser = newUser
                        self?.fetchAllUsers()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.allUsers = []
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                self?.currentUser = try? snapshot?.data(as: UserModel.self)
            }
        }
    }

    func fetchAllUsers() {
        db.collection("users").addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else { return }
            DispatchQueue.main.async {
                self?.allUsers = documents.compactMap { try? $0.data(as: UserModel.self) }
            }
        }
    }
}
