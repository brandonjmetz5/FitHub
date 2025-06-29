//
//  MainTabView.swift
//  FitHub
//
//  Created by brandon metz on 6/21/25.
//

import SwiftUI

enum Tab {
    case log, workouts, home, badges, settings
}

struct MainTabView: View {
    @ObservedObject var viewModel: AuthViewModel
    @ObservedObject var profileViewModel: ProfileViewModel

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            // Food Log tab
            NavigationStack {
                FoodLogView(
                    viewModel: FoodLogViewModel(),
                    profileViewModel: profileViewModel
                )
                .navigationTitle("Food Log")
            }
            .tabItem { Label("Log", systemImage: "fork.knife") }
            .tag(Tab.log)

            // Workout Tracker tab
            NavigationStack {
                WorkoutLogView()
            }
            .tabItem { Label("Workouts", systemImage: "dumbbell.fill") }
            .tag(Tab.workouts)

            // Home tab
            NavigationStack {
                HomeView(selectedTab: $selectedTab)
                    .navigationTitle("Home")
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(Tab.home)

            // Badges tab
            NavigationStack {
               StatsView()
            }
            .tabItem { Label("Badges", systemImage: "star.fill") }
            .tag(Tab.badges)
            
            
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
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(Tab.settings)
        }
        .environmentObject(profileViewModel)
    }
}

// MARK: - Preview

#Preview {
    MainTabView(
        viewModel: AuthViewModel(),
        profileViewModel: ProfileViewModel()
    )
}
