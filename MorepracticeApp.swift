//
//  MorepracticeApp.swift
//  Morepractice
//
//  Created by Fred Olivier on 17/09/2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck

@main
struct MorepracticeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        // Enable App Check debug provider factory
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)

        // Configure Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }

    // AppDelegate class for Firebase setup
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions:
                         [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            // FirebaseApp is already configured in MorepracticeApp.init()
            // No need to call FirebaseApp.configure() again here.
            return true
        }
    }
}
