
//
//  MainAppView.swift
//  Morepractice
//
//  Created by Fred Olivier on 03/10/2024.
//

// MainAppView.swift

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var scoreManager = ScoreManager()
    @StateObject var imageManager: ImageManager

    init() {
        let scoreManager = ScoreManager()
        _scoreManager = StateObject(wrappedValue: scoreManager)
        _imageManager = StateObject(wrappedValue: ImageManager(scoreManager: scoreManager))
    }

    var body: some View {
        NavigationView {
            ImageScoringView(scoreManager: scoreManager)
                .navigationBarItems(trailing: Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                })
                
        }
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
            .environmentObject(AuthViewModel()) // Provide AuthViewModel for previews
    }
}

