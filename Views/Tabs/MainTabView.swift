//
//  MainTabView.swift
//  FitHub
//
//  Created by brandon metz on 6/21/25.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: AuthViewModel
    @ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
        TabView {
            // Food Log tab
            NavigationStack {
                FoodLogView(
                    viewModel: FoodLogViewModel(),
                    profileViewModel: profileViewModel
                )
                .navigationTitle("Food Log")
            }
            .tabItem {
                Label("Log", systemImage: "fork.knife")
            }

            // Workout Tracker tab
            NavigationStack {
                WorkoutLogView()
            }
            .tabItem {
                Label("Workouts", systemImage: "dumbbell.fill")
            }

            // Home tab placeholder
            NavigationStack {
                Text("Home Screen Coming Soon")
                    .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            // Badges tab
            NavigationStack {
                Text("Badges")
                    .navigationTitle("Badges")
            }
            .tabItem {
                Label("Badges", systemImage: "star.fill")
            }

            // Settings / Profile tab
            NavigationStack {
                Form {
                    Section(header: Text("Profile & Goals")) {
                        NavigationLink("Edit Profile & Goals") {
                            ProfileView(viewModel: profileViewModel)
                        }
                    }
                    Section(header: Text("Account")) {
                        Button("Log Out", role: .destructive) {
                            viewModel.logOut()
                        }
                    }
                }
                .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        // Provide profile data to any subviews that need it
        .environmentObject(profileViewModel)
    }
}

#Preview {
    MainTabView(
        viewModel: AuthViewModel(),
        profileViewModel: ProfileViewModel()
    )
}
