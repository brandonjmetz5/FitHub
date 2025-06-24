//
//  WeightLogViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/24/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class WeightLogViewModel: ObservableObject {
    @Published var logs: [WeightLog] = []
    @Published var latestLog: WeightLog?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    /// Start listening for the most recent 30 logs, sorted by date descending.
    func fetchLogs() {
        guard let uid = userId else { return }
        listener = db
            .collection("users").document(uid)
            .collection("weightLogs")
            .order(by: "date", descending: true)
            .limit(to: 30)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let docs = snapshot?.documents else {
                    print("WeightLog fetch error:", error?.localizedDescription ?? "")
                    return
                }
                let fetched = docs.compactMap { try? $0.data(as: WeightLog.self) }
                DispatchQueue.main.async {
                    self?.logs = fetched
                    self?.latestLog = fetched.first
                }
            }
    }

    /// Add a new weight entry for the given date (defaults to now).
    func addLog(weight: Double, date: Date = .now, completion: ((Error?) -> Void)? = nil) {
        guard let uid = userId else { return }
        let newLog = WeightLog(id: nil, date: date, weight: weight)
        do {
            _ = try db
                .collection("users").document(uid)
                .collection("weightLogs")
                .addDocument(from: newLog) { error in
                    DispatchQueue.main.async {
                        completion?(error)
                    }
                }
        } catch {
            print("Error adding WeightLog:", error)
            completion?(error)
        }
    }

    deinit {
        listener?.remove()
    }
}
