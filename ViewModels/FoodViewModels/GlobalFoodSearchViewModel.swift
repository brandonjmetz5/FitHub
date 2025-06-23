//
//  GlobalFoodSearchViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class GlobalFoodSearchViewModel: ObservableObject {
    @Published var allFoods: [GlobalFood] = []
    @Published var filteredFoods: [GlobalFood] = []
    @Published var isLoading = false
    @Published var searchQuery: String = "" {
        didSet {
            filterFoods()
        }
    }

    private var db = Firestore.firestore()
    private var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        fetchGlobalFoods()
    }

    func fetchGlobalFoods() {
        isLoading = true

        db.collection("globalFoods")
            .order(by: "createdAt", descending: true)
            .limit(to: 1000)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        print("Error loading global foods:", error.localizedDescription)
                        return
                    }

                    self.allFoods = snapshot?.documents.compactMap {
                        try? $0.data(as: GlobalFood.self)
                    } ?? []

                    self.filterFoods()
                }
            }
    }

    private func filterFoods() {
        let query = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            filteredFoods = []
        } else {
            filteredFoods = allFoods.filter {
                $0.name.lowercased().contains(query) ||
                ($0.brand ?? "").lowercased().contains(query)
            }
        }
    }

    func reportFood(_ food: GlobalFood) {
        guard let foodId = food.id, let userId = currentUserId else { return }

        let foodRef = db.collection("globalFoods").document(foodId)

        db.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                let snapshot = try transaction.getDocument(foodRef)
                guard var data = snapshot.data() else { return nil }

                var currentCount = data["reportCount"] as? Int ?? 0
                var reporterIds = data["reporterIds"] as? [String] ?? []

                if reporterIds.contains(userId) {
                    // User has already reported this food
                    return nil
                }

                currentCount += 1
                reporterIds.append(userId)

                if currentCount >= 10 {
                    transaction.deleteDocument(foodRef)
                } else {
                    data["reportCount"] = currentCount
                    data["reporterIds"] = reporterIds
                    data["isReported"] = true
                    transaction.setData(data, forDocument: foodRef)
                }

                return nil
            } catch {
                print("Transaction error: \(error.localizedDescription)")
                return nil
            }
        } completion: { (_, error) in
            if let error = error {
                print("Failed to report food: \(error.localizedDescription)")
            }
        }
    }
}

