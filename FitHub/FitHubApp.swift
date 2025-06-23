//
//  FitHubApp.swift
//  FitHub
//
//  Created by brandon metz on 6/21/25.
//

//import SwiftUI
//import Firebase
//
//@main
//struct FitHubApp: App {
//    @StateObject private var authViewModel = AuthViewModel()
//
//    init() {
//        FirebaseApp.configure()
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            if authViewModel.isLoggedIn {
//                MainTabView(viewModel: authViewModel)
//            } else {
//                LoginView(viewModel: authViewModel)
//            }
//        }
//    }
//}
//

//
//  FitHubApp.swift
//  FitHub
//
//  Created by brandon metz on 6/21/25.
//

import SwiftUI
import Firebase

@main
struct FitHubApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                Group {
                    if profileViewModel.isLoading {
                        ProgressView("Loading Profile…")
                    } else if profileViewModel.profile == nil {
                        ProfileSetupView(viewModel: profileViewModel)
                    } else {
                        MainTabView(
                            viewModel: authViewModel,
                            profileViewModel: profileViewModel
                        )
                    }
                }
                .onAppear {
                    profileViewModel.fetchProfile()
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}
