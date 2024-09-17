//
//  ContentView.swift
//  Morepractice
//
//  Created by Fred Olivier on 17/09/2024.
//
// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel() // Initialize AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                MainAppView()
                    .environmentObject(authViewModel) // Pass AuthViewModel to MainAppView
            } else {
                SignInView()
                    .environmentObject(authViewModel) // Pass AuthViewModel to SignInView
            }
        }
        .onAppear {
            // Optionally, perform any additional setup on appear
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel()) // Provide AuthViewModel for previews
    }
}
