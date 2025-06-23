//
//  WorkoutTemplatesViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class WorkoutTemplatesViewModel: ObservableObject {
    @Published var presets: [WorkoutTemplate] = []
    @Published var customTemplates: [WorkoutTemplate] = []
    
    private let db = Firestore.firestore()
    private var userId: String? { Auth.auth().currentUser?.uid }

    init() {
        fetchPresets()
        fetchCustomTemplates()
    }

    /// Fetch workout presets one-time using getDocuments
    func fetchPresets() {
        db.collection("workoutTemplates")
          .whereField("isPreset", isEqualTo: true)
          .getDocuments { snapshot, error in
              if let error = error {
                  print("Error fetching presets: \(error)")
                  return
              }
              self.presets = snapshot?.documents
                  .compactMap { try? $0.data(as: WorkoutTemplate.self) }
                  ?? []
          }
    }

    /// Fetch user-specific custom templates one-time
    func fetchCustomTemplates() {
        guard let uid = userId else { return }
        db.collection("users")
          .document(uid)
          .collection("customWorkoutTemplates")
          .getDocuments { snapshot, error in
              if let error = error {
                  print("Error fetching custom templates: \(error)")
                  return
              }
              self.customTemplates = snapshot?.documents
                  .compactMap { try? $0.data(as: WorkoutTemplate.self) }
                  ?? []
          }
    }

    /// Save a new custom template under the user's namespace
    func createCustomTemplate(_ template: WorkoutTemplate) {
        guard let uid = userId else { return }
        var newTemplate = template
        let ref = db.collection("users")
                    .document(uid)
                    .collection("customWorkoutTemplates")
                    .document()
        newTemplate.id = ref.documentID
        newTemplate.isPreset = false
        newTemplate.userId = uid

        do {
            try ref.setData(from: newTemplate)
            // Refresh custom list
            fetchCustomTemplates()
        } catch {
            print("Error creating custom template: \(error)")
        }
    }

    /// Delete a custom template
    func deleteCustomTemplate(_ template: WorkoutTemplate) {
        guard let uid = userId, let id = template.id else { return }
        db.collection("users")
          .document(uid)
          .collection("customWorkoutTemplates")
          .document(id)
          .delete { error in
              if let error = error {
                  print("Error deleting template: \(error)")
              } else {
                  self.fetchCustomTemplates()
              }
          }
    }
}
