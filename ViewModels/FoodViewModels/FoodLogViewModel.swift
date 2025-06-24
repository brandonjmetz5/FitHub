//
//  FoodLogViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

/// A simple model for daily calorie totals, used in charts and streak logic.
struct CalorieEntry: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double
}

class FoodLogViewModel: ObservableObject {
    // MARK: — Published state
    @Published private(set) var entries: [FoodEntry] = []
    @Published var todaysEntries: [FoodEntry] = []
    @Published var weeklyCalories: [CalorieEntry] = []
    @Published var dailyCalorieAllowance: Double = 0
    @Published var selectedDate: Date = Date() {
        didSet { loadLog(for: selectedDate) }
    }

    // MARK: — Private
    private let db = Firestore.firestore()
    private var allowanceListener: ListenerRegistration?
    private var userId: String? { Auth.auth().currentUser?.uid }

    // MARK: — Init / Deinit
    init() {
        fetchTodaysEntries()
        listenToCalorieAllowance()
    }

    deinit {
        allowanceListener?.remove()
    }

    // MARK: — Fetchers

    /// Loads entries for today
    func fetchTodaysEntries() {
        loadLog(for: Date())
    }

    /// Builds a 7-day series of total calories, for charts and streaks
    func fetchWeeklyCalories() {
        guard let uid = userId else { return }
        var temp: [CalorieEntry] = []
        let group = DispatchGroup()

        for offset in 0...6 {
            let day = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            let key = Self.dateKey(for: day)
            group.enter()
            db.collection("users")
              .document(uid)
              .collection("foodLogs")
              .document(key)
              .collection("entries")
              .getDocuments { snapshot, _ in
                  let cals = snapshot?.documents
                      .compactMap { try? $0.data(as: FoodEntry.self) }
                      .reduce(0) { $0 + $1.calories } ?? 0
                  temp.append(CalorieEntry(date: day, calories: Double(cals)))
                  group.leave()
              }
        }

        group.notify(queue: .main) {
            self.weeklyCalories = temp.sorted { $0.date < $1.date }
        }
    }

    /// Internal loader for any single date
    private func loadLog(for date: Date) {
        guard let uid = userId else { return }
        let key = Self.dateKey(for: date)
        db.collection("users")
          .document(uid)
          .collection("foodLogs")
          .document(key)
          .collection("entries")
          .getDocuments { snapshot, _ in
              let docs = snapshot?.documents.compactMap {
                  try? $0.data(as: FoodEntry.self)
              } ?? []
              DispatchQueue.main.async {
                  self.entries = docs
                  if Calendar.current.isDate(date, inSameDayAs: Date()) {
                      self.todaysEntries = docs
                  } else {
                      self.todaysEntries = []
                  }
              }
          }
    }

    // MARK: — Computed Metrics

    var totalCalories: Double { entries.reduce(0) { $0 + Double($1.calories) } }
    var totalProtein: Double  { entries.reduce(0) { $0 + Double($1.protein) } }
    var totalCarbs: Double    { entries.reduce(0) { $0 + Double($1.carbs) } }
    var totalFat: Double      { entries.reduce(0) { $0 + Double($1.fat) } }

    /// Consecutive days (starting today) with ≥1 entry
    var streak: Int {
        var count = 0
        let sorted = weeklyCalories.sorted { $0.date > $1.date }
        for entry in sorted {
            guard entry.calories > 0 else { break }
            count += 1
        }
        return count
    }

    // MARK: — Firestore Listeners

    private func listenToCalorieAllowance() {
        guard let uid = userId else { return }
        allowanceListener = db.collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let data = snapshot?.data() else { return }
                DispatchQueue.main.async {
                    self?.dailyCalorieAllowance = data["dailyCalorieAllowance"] as? Double ?? 0
                }
            }
    }

    // MARK: — Helpers

    private static func dateKey(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    // MARK: — CRUD Operations

    func addFoodEntry(_ entry: FoodEntry) {
        guard let uid = userId else { return }
        let key = Self.dateKey(for: Date())
        let ref = db.collection("users")
            .document(uid)
            .collection("foodLogs")
            .document(key)
            .collection("entries")
            .document(entry.id)

        do {
            try ref.setData(from: entry)
            DispatchQueue.main.async {
                self.entries.append(entry)
                self.todaysEntries.append(entry)
            }
            saveToGlobalFoodsIfNew(entry)
        } catch {
            print("Error saving entry: \(error.localizedDescription)")
        }
    }

    func updateFoodEntry(_ entry: FoodEntry) {
        guard let uid = userId else { return }
        let key = Self.dateKey(for: Date())
        let ref = db.collection("users")
            .document(uid)
            .collection("foodLogs")
            .document(key)
            .collection("entries")
            .document(entry.id)

        do {
            try ref.setData(from: entry)
            DispatchQueue.main.async {
                if let idx = self.entries.firstIndex(where: { $0.id == entry.id }) {
                    self.entries[idx] = entry
                }
                if let idx = self.todaysEntries.firstIndex(where: { $0.id == entry.id }) {
                    self.todaysEntries[idx] = entry
                }
            }
        } catch {
            print("Error updating entry: \(error.localizedDescription)")
        }
    }

    func deleteEntries(for mealType: MealType, at offsets: IndexSet) {
        guard let uid = userId else { return }
        let key = Self.dateKey(for: Date())
        let entriesRef = db.collection("users")
            .document(uid)
            .collection("foodLogs")
            .document(key)
            .collection("entries")

        let toDelete = offsets.map { idx in
            todaysEntries.filter { $0.meal == mealType }[idx]
        }
        toDelete.forEach { entry in
            entriesRef.document(entry.id).delete { error in
                if let error = error {
                    print("Error deleting entry: \(error.localizedDescription)")
                }
            }
        }
        DispatchQueue.main.async {
            self.entries.removeAll { toDelete.contains($0) }
            self.todaysEntries.removeAll { toDelete.contains($0) }
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
}
