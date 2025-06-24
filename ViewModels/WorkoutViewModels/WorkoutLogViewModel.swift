//
//  WorkoutLogViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class WorkoutLogViewModel: ObservableObject {
    // MARK: — Published state
    @Published var logs: [WorkoutLog] = []
    @Published var todayWorkout: WorkoutLog?
    @Published var nextPlannedWorkout: WorkoutTemplate?

    // MARK: — Private
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var userId: String? { Auth.auth().currentUser?.uid }

    // MARK: — Init / Deinit
    init() {
        fetchAllLogs()
        fetchNextWorkout()
    }

    deinit {
        listener?.remove()
    }

    // MARK: — Fetchers

    /// Starts a realtime listener for all workout logs, updating today's log too
    func fetchAllLogs() {
        guard let uid = userId else { return }
        listener = db
            .collection("users").document(uid)
            .collection("workoutLogs")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let docs = snapshot?.documents {
                    let fetched = docs.compactMap { try? $0.data(as: WorkoutLog.self) }
                    DispatchQueue.main.async {
                        self.logs = fetched
                        self.todayWorkout = fetched.first(where: {
                            Calendar.current.isDateInToday($0.date)
                        })
                    }
                } else if let error = error {
                    print("Error fetching workout logs: \(error.localizedDescription)")
                }
            }
    }

    /// Pulls the next scheduled workout (if you have a `scheduledWorkouts` sub-collection)
    func fetchNextWorkout() {
        guard let uid = userId else { return }
        db
          .collection("users").document(uid)
          .collection("scheduledWorkouts")
          .order(by: "date", descending: false)   // ← descending:false == ascending
          .limit(to: 1)
          .getDocuments { [weak self] snapshot, error in
              if let error = error {
                  print("Error fetching next workout: \(error.localizedDescription)")
                  return
              }
              if let doc = snapshot?.documents.first,
                 let template = try? doc.data(as: WorkoutTemplate.self) {
                  DispatchQueue.main.async {
                      self?.nextPlannedWorkout = template
                  }
              }
          }
    }


    // MARK: — CRUD Operations

    /// Logs a new workout (optionally based on a template)
    func logWorkout(using template: WorkoutTemplate?, with exercises: [ExerciseEntry], completion: ((Error?) -> Void)? = nil) {
        guard let uid = userId else { return }
        let newLog = WorkoutLog(
            id: nil,
            date: Date(),
            templateID: template?.id,
            performedExercises: exercises
        )
        do {
            _ = try db.collection("users")
                       .document(uid)
                       .collection("workoutLogs")
                       .addDocument(from: newLog) { error in
                           DispatchQueue.main.async {
                               completion?(error)
                           }
                       }
        } catch {
            print("Error logging workout: \(error.localizedDescription)")
            completion?(error)
        }
    }

    /// Updates an existing workout log
    func updateWorkoutLog(_ log: WorkoutLog) {
        guard let uid = userId, let id = log.id else { return }
        do {
            try db.collection("users")
                  .document(uid)
                  .collection("workoutLogs")
                  .document(id)
                  .setData(from: log)
        } catch {
            print("Error updating workout log: \(error.localizedDescription)")
        }
    }

    /// Deletes a workout log
    func deleteWorkoutLog(_ log: WorkoutLog) {
        guard let uid = userId, let id = log.id else { return }
        db.collection("users")
          .document(uid)
          .collection("workoutLogs")
          .document(id)
          .delete { error in
              if let error = error {
                  print("Error deleting workout log: \(error.localizedDescription)")
              }
          }
    }
}
