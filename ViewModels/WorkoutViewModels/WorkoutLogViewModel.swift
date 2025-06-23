//
//  WorkoutLogViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/23/25.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class WorkoutLogViewModel: ObservableObject {
    @Published var logs: [WorkoutLog] = []
    private let db = Firestore.firestore()
    private var userId: String? { Auth.auth().currentUser?.uid }

    init() {
        fetchAllLogs()
    }

    /// Fetch all workout logs for the current user
    func fetchAllLogs() {
        guard let uid = userId else { return }
        db.collection("users")
          .document(uid)
          .collection("workoutLogs")
          .order(by: "date", descending: true)
          .addSnapshotListener { snapshot, error in
              if let error = error {
                  print("Error fetching workout logs: \(error)")
                  return
              }
              self.logs = snapshot?.documents
                  .compactMap { try? $0.data(as: WorkoutLog.self) }
                  ?? []
          }
    }

    /// Returns today's log if it exists
    var todayLog: WorkoutLog? {
        let todayStart = Calendar.current.startOfDay(for: Date())
        return logs.first {
            Calendar.current.isDate($0.date, inSameDayAs: todayStart)
        }
    }

    /// Create a new log for today (or any date), copying from a template if provided
    func logWorkout(using template: WorkoutTemplate?, with exercises: [ExerciseEntry]) {
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
                       .addDocument(from: newLog)
        } catch {
            print("Error logging workout: \(error)")
        }
    }

    /// Edit an existing log (e.g. update performedExercises)
    func updateWorkoutLog(_ log: WorkoutLog) {
        guard let uid = userId, let id = log.id else { return }
        do {
            try db.collection("users")
                  .document(uid)
                  .collection("workoutLogs")
                  .document(id)
                  .setData(from: log)
        } catch {
            print("Error updating workout log: \(error)")
        }
    }

    /// Delete an existing workout log
    func deleteWorkoutLog(_ log: WorkoutLog) {
        guard let uid = userId, let id = log.id else { return }
        db.collection("users")
          .document(uid)
          .collection("workoutLogs")
          .document(id)
          .delete { error in
              if let error = error {
                  print("Error deleting workout log: \(error)")
              }
          }
    }
}

