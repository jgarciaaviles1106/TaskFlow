//
//  ContentView.swift
//  TaskFlow
//
//  Created by Julio Garcìa on 25/11/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.userSession != nil {
                ProjectListView()
            } else {
                AuthView()
            }
        }
        .environmentObject(authViewModel)
    }
}
