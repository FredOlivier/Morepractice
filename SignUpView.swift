//
//  SignUpView.swift
//  Morepractice
//
//  Created by Fred Olivier on 03/10/2024.
//

import Foundation


import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()

            TextField("Name", text: $name)
                .autocapitalization(.words)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                if password != confirmPassword {
                    self.errorMessage = "Passwords do not match"
                    return
                }

                authViewModel.signUp(name: name, email: email, password: password) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .navigationBarTitle("Sign Up", displayMode: .inline)
    }
}
