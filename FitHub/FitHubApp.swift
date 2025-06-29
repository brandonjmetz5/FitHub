//
//  FitHubApp.swift
//  FitHub
//
//  Created by brandon metz on 6/21/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@main
struct FitHubApp: App {
    // Authentication & profile flow VMs
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    // Workout templates VM for seeding and runtime access
    @StateObject private var templatesVM = WorkoutTemplatesViewModel()
    
    init() {
        FirebaseApp.configure()
        seedDefaultTemplatesIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
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
            .environmentObject(templatesVM)
        }
    }
    
    /// On first launch, checks for any preset templates in Firestore.
    /// If none exist, seeds the `workoutTemplates` collection with two defaults.
    private func seedDefaultTemplatesIfNeeded() {
        let db = Firestore.firestore()
        let presetsQuery = db.collection("workoutTemplates")
            .whereField("isPreset", isEqualTo: true)
        
        presetsQuery.getDocuments { snapshot, error in
            guard let count = snapshot?.documents.count, error == nil else {
                print("Error checking for existing presets: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            guard count == 0 else { return }
            
            let defaultWorkouts: [WorkoutTemplate] = [
                WorkoutTemplate(
                    id: nil,
                    name: "Full Body Beginner",
                    isPreset: true,
                    userId: nil,
                    exercises: [
                        Exercise(name: "Goblet Squat", inputType: .strength, muscleGroup: .quads),
                        Exercise(name: "Push-ups",     inputType: .strength, muscleGroup: .chest),
                        Exercise(name: "Plank",        inputType: .strength, muscleGroup: .core),
                        Exercise(name: "Jumping Jacks", inputType: .cardio, muscleGroup: .cardio)
                    ]
                ),
                WorkoutTemplate(
                    id: nil,
                    name: "Cardio Blast",
                    isPreset: true,
                    userId: nil,
                    exercises: [
                        Exercise(name: "Running",          inputType: .cardio, muscleGroup: .cardio),
                        Exercise(name: "Burpees",          inputType: .cardio, muscleGroup: .cardio),
                        Exercise(name: "Mountain Climbers", inputType: .cardio, muscleGroup: .cardio)
                    ]
                )
            ]
            
            for var template in defaultWorkouts {
                let ref = db.collection("workoutTemplates").document()
                template.id = ref.documentID
                do {
                    try ref.setData(from: template)
                } catch {
                    print("Error seeding default template '\(template.name)': \(error.localizedDescription)")
                }
            }
        }
    }
}
