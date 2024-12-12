
//  AuthViewModel.swift
//  Morepractice
//
//  Created by Fred Olivier on 03/10/2024.
//

// AuthViewModel.swift

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var userSession: User?
    @Published var isSignedIn: Bool = false

    private var db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        self.userSession = Auth.auth().currentUser
        self.isSignedIn = self.userSession != nil

        // Listen for authentication state changes
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.userSession = user
            self?.isSignedIn = user != nil
        }
    }

    deinit {
        // Remove the listener when the view model is deallocated
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp(name: String, email: String, password: String, completion: @escaping (Error?) -> Void) {
        // Create a new user with email and password
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error)
                return
            }

            guard let user = result?.user else {
                completion(NSError(domain: "User creation failed", code: -1, userInfo: nil))
                return
            }

            // Add user profile to Firestore
            let userData: [String: Any] = [
                "uid": user.uid,
                "name": name,
                "email": email,
                "created_at": Timestamp(date: Date())
            ]

            self?.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    completion(error)
                } else {
                    self?.userSession = user
                    self?.isSignedIn = true
                    completion(nil)
                }
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        // Sign in with email and password
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error)
            } else {
                self?.userSession = result?.user
                self?.isSignedIn = true
                completion(nil)
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.isSignedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

