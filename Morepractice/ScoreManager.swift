//
//  ScoreManager.swift
//  Morepractice
//
//  Created by Fred Olivier on 19/09/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ScoreManager: ObservableObject {
    @Published var scores: [Score] = []
    @Published var imagePreference: [String: Double] = [:]

    private var db = Firestore.firestore()
    private var user: User?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        self.user = Auth.auth().currentUser
        if self.user != nil {
            loadImagePreferences()
            observeScores()
        }

        // Store the handle for the auth state listener
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.user = user
            if user != nil {
                self?.loadImagePreferences()
                self?.observeScores()
            } else {
                // User signed out, you can handle clearing data if needed
                DispatchQueue.main.async {
                    self?.scores = []
                    self?.imagePreference = [:]
                }
            }
        }
    }

    deinit {
        // Clean up the auth state listener when ScoreManager is deallocated
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }


    /// Loads image preferences from Firestore
    private func loadImagePreferences() {
        guard let user = self.user else { return }

        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching image preferences: \(error)")
                return
            }

            if let data = snapshot?.data(), let prefs = data["imagePreference"] as? [String: Double] {
                DispatchQueue.main.async {
                    self?.imagePreference = prefs
                }
            } else {
                // Initialize with default preferences if not present
                DispatchQueue.main.async {
                    self?.imagePreference = [:]
                }
            }
        }
    }

    /// Adds a new score and updates image preferences
    func addScore(slider1: Double, slider2: Double, image1: String, image2: String, image1URL: String, image2URL: String, relationalScore: Double) {
        guard let user = self.user else { return }

        let scoreID = UUID().uuidString
        let scoreData: [String: Any] = [
            "slider1": slider1,
            "slider2": slider2,
            "image1_id": image1,
            "image2_id": image2,
            "image1_url": image1URL,
            "image2_url": image2URL,
            "relational_score": relationalScore,
            "date": Timestamp(date: Date())
        ]

        db.collection("users").document(user.uid).collection("scores").document(scoreID).setData(scoreData) { [weak self] error in
            if let error = error {
                print("Error adding score: \(error)")
            } else {
                // Optionally, update image preferences based on the new score
                self?.updateImagePreferences(image1: image1, image2: image2, slider1: slider1, slider2: slider2)
            }
        }
    }


    /// Observes scores from Firestore and updates the local scores array
    func observeScores() {
        guard let user = self.user else { return }

        db.collection("users").document(user.uid).collection("scores").order(by: "date", descending: true)
            .addSnapshotListener { [weak self] (snapshot, error) in
                if let error = error {
                    print("Error observing scores: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                var updatedScores: [Score] = []

                for document in documents {
                    let data = document.data()
                    if let slider1 = data["slider1"] as? Double,
                       let slider2 = data["slider2"] as? Double,
                       let image1_id = data["image1_id"] as? String,
                       let image2_id = data["image2_id"] as? String,
                       let image1_url = data["image1_url"] as? String,
                       let image2_url = data["image2_url"] as? String,
                       let relational_score = data["relational_score"] as? Double,
                       let date = (data["date"] as? Timestamp)?.dateValue() {
                        let score = Score(
                            id: UUID(uuidString: document.documentID) ?? UUID(),
                            slider1: slider1,
                            slider2: slider2,
                            image1: image1_id,
                            image2: image2_id,
                            image1URL: image1_url,
                            image2URL: image2_url,
                            relationalScore: relational_score,
                            date: date
                        )
                        updatedScores.append(score)
                    }
                }

                DispatchQueue.main.async {
                    self?.scores = updatedScores
                }
            }
    }


    /// Updates image preferences based on user input
    private func updateImagePreferences(image1: String, image2: String, slider1: Double, slider2: Double) {
        // Example logic: higher slider value increases preference, lower decreases
        // Adjust as per your application's logic

        var updatedPreferences = imagePreference

        // Update preference for image1
        let delta1 = (slider1 >= 0.5) ? 0.1 : -0.1
        updatedPreferences[image1] = (updatedPreferences[image1] ?? 0.5) + delta1

        // Update preference for image2
        let delta2 = (slider2 >= 0.5) ? 0.1 : -0.1
        updatedPreferences[image2] = (updatedPreferences[image2] ?? 0.5) + delta2

        // Clamp values between 0.0 and 1.0
        for (key, value) in updatedPreferences {
            updatedPreferences[key] = min(max(value, 0.0), 1.0)
        }

        self.imagePreference = updatedPreferences

        // Save updated preferences back to Firestore
        guard let user = self.user else { return }
        db.collection("users").document(user.uid).updateData([
            "imagePreference": updatedPreferences
        ]) { error in
            if let error = error {
                print("Error updating image preferences: \(error)")
            }
        }
    }
}
