//
//  FoodLogViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//
//class FoodLogViewModel: ObservableObject {
//    @Published var entries: [FoodEntry] = []
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    var totalCalories: Int {
//        entries.reduce(0) { $0 + $1.calories }
//    }
//
//    var totalProtein: Int {
//        entries.reduce(0) { $0 + $1.protein }
//    }
//
//    var totalCarbs: Int {
//        entries.reduce(0) { $0 + $1.carbs }
//    }
//
//    var totalFat: Int {
//        entries.reduce(0) { $0 + $1.fat }
//    }
//
//    private var db = Firestore.firestore()
//    private var userId: String? {
//        Auth.auth().currentUser?.uid
//    }
//
//    private var todayEntriesRef: CollectionReference? {
//        guard let userId else { return nil }
//        let dateKey = FoodLogViewModel.todayDateKey()
//        return db.collection("users").document(userId)
//            .collection("foodLogs").document(dateKey)
//            .collection("entries")
//    }
//
//    init() {
//        loadTodayLog()
//    }
//
//    func loadTodayLog() {
//        guard let entriesRef = todayEntriesRef else { return }
//
//        isLoading = true
//        entriesRef.getDocuments { snapshot, error in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                if let error = error {
//                    self.errorMessage = error.localizedDescription
//                    return
//                }
//
//                guard let documents = snapshot?.documents else {
//                    self.entries = []
//                    return
//                }
//
//                self.entries = documents.compactMap {
//                    try? $0.data(as: FoodEntry.self)
//                }
//            }
//        }
//    }
//
//    func addFoodEntry(_ entry: FoodEntry) {
//        guard let entriesRef = todayEntriesRef else { return }
//
//        do {
//            try entriesRef.document(entry.id).setData(from: entry)
//            entries.append(entry)
//            saveToGlobalFoodsIfNew(entry)
//        } catch {
//            print("Error saving entry: \(error.localizedDescription)")
//        }
//    }
//
//    func updateFoodEntry(_ entry: FoodEntry) {
//        guard let entriesRef = todayEntriesRef else { return }
//        do {
//            try entriesRef.document(entry.id).setData(from: entry)
//            if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
//                entries[idx] = entry
//            }
//        } catch {
//            print("Error updating entry: \(error.localizedDescription)")
//        }
//    }
//
//    private func saveToGlobalFoodsIfNew(_ entry: FoodEntry) {
//        let globalRef = db.collection("globalFoods")
//
//        let nameKey = entry.name
//            .lowercased()
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//            .replacingOccurrences(of: "[^a-z0-9]",
//                                  with: "",
//                                  options: .regularExpression)
//        let brandKey = (entry.brand ?? "")
//            .lowercased()
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//            .replacingOccurrences(of: "[^a-z0-9]",
//                                  with: "",
//                                  options: .regularExpression)
//
//        globalRef
//            .whereField("nameKey", isEqualTo: nameKey)
//            .whereField("brandKey", isEqualTo: brandKey)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error checking global foods:", error.localizedDescription)
//                    return
//                }
//                guard let docs = snapshot?.documents, docs.isEmpty else {
//                    return // already exists
//                }
//
//                let newDoc = globalRef.document()
//                newDoc.setData([
//                    "id": newDoc.documentID,
//                    "name": entry.name,
//                    "brand": entry.brand ?? "",
//                    "nameKey": nameKey,
//                    "brandKey": brandKey,
//                    "calories": entry.calories,
//                    "protein": entry.protein,
//                    "carbs": entry.carbs,
//                    "fat": entry.fat,
//                    "unit": entry.unit,
//                    "quantity": entry.quantity,
//                    "isUserCreated": true,
//                    "creatorId": self.userId ?? "",
//                    "reportCount": 0,
//                    "isReported": false,
//                    "createdAt": Timestamp()
//                ]) { error in
//                    if let error = error {
//                        print("Failed to save to globalFoods:", error.localizedDescription)
//                    }
//                }
//            }
//    }
//
//    func deleteEntries(for mealType: MealType, at offsets: IndexSet) {
//        let toDelete = offsets.map { idx in
//            entries.filter { $0.meal == mealType }[idx]
//        }
//        toDelete.forEach { entry in
//            todayEntriesRef?.document(entry.id).delete { error in
//                if let error = error {
//                    print("Error deleting entry: \(error.localizedDescription)")
//                }
//            }
//        }
//        entries.removeAll { toDelete.contains($0) }
//    }
//
//    static func todayDateKey() -> String {
//        let fmt = DateFormatter()
//        fmt.dateFormat = "yyyy-MM-dd"
//        return fmt.string(from: Date())
//    }
//}
//


//
//  FoodLogViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FoodLogViewModel: ObservableObject {
    @Published var entries: [FoodEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: — Date navigation
    @Published var selectedDate: Date = Date() {
        didSet { loadLog(for: selectedDate) }
    }

    var totalCalories: Int {
        entries.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Int {
        entries.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Int {
        entries.reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Int {
        entries.reduce(0) { $0 + $1.fat }
    }

    private var db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    /// Firestore ref for today’s entries (legacy helper—no change)
    private var todayEntriesRef: CollectionReference? {
        guard let userId else { return nil }
        let dateKey = FoodLogViewModel.todayDateKey()
        return db.collection("users").document(userId)
            .collection("foodLogs").document(dateKey)
            .collection("entries")
    }

    /// Firestore ref for any date’s entries
    private func entriesRef(for date: Date) -> CollectionReference? {
        guard let userId = userId else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let key = fmt.string(from: date)
        return db.collection("users")
            .document(userId)
            .collection("foodLogs")
            .document(key)
            .collection("entries")
    }

    /// Load entries for a given date
    func loadLog(for date: Date) {
        guard let ref = entriesRef(for: date) else { return }
        isLoading = true
        ref.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.entries = snapshot?.documents.compactMap {
                    try? $0.data(as: FoodEntry.self)
                } ?? []
            }
        }
    }

    /// Initializer now loads based on `selectedDate`
    init() {
        loadLog(for: selectedDate)
    }

    // Legacy helper (still available if needed)
    func loadTodayLog() {
        guard let entriesRef = todayEntriesRef else { return }
        isLoading = true
        entriesRef.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = snapshot?.documents else {
                    self.entries = []
                    return
                }
                self.entries = documents.compactMap {
                    try? $0.data(as: FoodEntry.self)
                }
            }
        }
    }

    // MARK: — Existing CRUD methods

    func addFoodEntry(_ entry: FoodEntry) {
        guard let entriesRef = todayEntriesRef else { return }
        do {
            try entriesRef.document(entry.id).setData(from: entry)
            entries.append(entry)
            saveToGlobalFoodsIfNew(entry)
        } catch {
            print("Error saving entry: \(error.localizedDescription)")
        }
    }

    func updateFoodEntry(_ entry: FoodEntry) {
        guard let entriesRef = todayEntriesRef else { return }
        do {
            try entriesRef.document(entry.id).setData(from: entry)
            if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[idx] = entry
            }
        } catch {
            print("Error updating entry: \(error.localizedDescription)")
        }
    }

    private func saveToGlobalFoodsIfNew(_ entry: FoodEntry) {
        let globalRef = db.collection("globalFoods")
        let nameKey = entry.name
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)
        let brandKey = (entry.brand ?? "")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^a-z0-9]", with: "", options: .regularExpression)

        globalRef
            .whereField("nameKey", isEqualTo: nameKey)
            .whereField("brandKey", isEqualTo: brandKey)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking global foods:", error.localizedDescription)
                    return
                }
                guard let docs = snapshot?.documents, docs.isEmpty else { return }
                let newDoc = globalRef.document()
                newDoc.setData([
                    "id": newDoc.documentID,
                    "name": entry.name,
                    "brand": entry.brand ?? "",
                    "nameKey": nameKey,
                    "brandKey": brandKey,
                    "calories": entry.calories,
                    "protein": entry.protein,
                    "carbs": entry.carbs,
                    "fat": entry.fat,
                    "unit": entry.unit,
                    "quantity": entry.quantity,
                    "isUserCreated": true,
                    "creatorId": self.userId ?? "",
                    "reportCount": 0,
                    "isReported": false,
                    "createdAt": Timestamp()
                ]) { error in
                    if let error = error {
                        print("Failed to save to globalFoods:", error.localizedDescription)
                    }
                }
            }
    }

    func deleteEntries(for mealType: MealType, at offsets: IndexSet) {
        let toDelete = offsets.map { idx in
            entries.filter { $0.meal == mealType }[idx]
        }
        toDelete.forEach { entry in
            todayEntriesRef?.document(entry.id).delete { error in
                if let error = error {
                    print("Error deleting entry: \(error.localizedDescription)")
                }
            }
        }
        entries.removeAll { toDelete.contains($0) }
    }

    static func todayDateKey() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }
}
