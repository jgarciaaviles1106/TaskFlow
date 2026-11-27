//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Creado por Julio Garcìa en 25/11/26.
//

import SwiftUI
import FirebaseCore

@main
struct TaskFlowApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

