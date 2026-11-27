//
//  AuthView.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isRegisterMode = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .desarrollador

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "checklist.checked")
                        .font(.system(size: 54))
                        .foregroundColor(.blue)
                    Text("TaskFlow")
                        .font(.largeTitle.bold())
                    Text(isRegisterMode ? "Crea tu cuenta de equipo" : "Inicia sesión para gestionar tus proyectos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                VStack(spacing: 14) {
                    if isRegisterMode {
                        TextField("Nombre completo", text: $name)
                            .textFieldStyle(.roundedBorder)

                        Picker("Rol en el equipo", selection: $selectedRole) {
                            ForEach(UserRole.allCases, id: \.self) { role in
                                Text(role.rawValue).tag(role)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                    TextField("Correo electrónico", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Contraseña (mín. 6 caracteres)", text: $password)
                        .textFieldStyle(.roundedBorder)
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    if isRegisterMode {
                        authViewModel.register(name: name, email: email, password: password, role: selectedRole)
                    } else {
                        authViewModel.login(email: email, password: password)
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(isRegisterMode ? "Registrarme" : "Iniciar Sesión")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.count < 6 || (isRegisterMode && name.isEmpty))

                Button {
                    withAnimation {
                        isRegisterMode.toggle()
                        authViewModel.errorMessage = nil
                    }
                } label: {
                    Text(isRegisterMode ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate aquí")
                        .font(.footnote)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}
