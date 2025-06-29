//
//  BadgesViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/26/25.
//



import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Badge: Identifiable {
    let id: String                   // badge type (e.g., "proteinWarrior")
    let tier: BadgeTier             // current tier
    let timesEarnedByTier: [BadgeTier: Int]  // how many times each tier earned
    let lastAwarded: Date?          // when this badge was last earned

    func timesEarned(for tier: BadgeTier) -> Int {
        timesEarnedByTier[tier] ?? 0
    }
}

class BadgesViewModel: ObservableObject {
    @Published var badges: [Badge] = []
    @Published var isLoading: Bool = true
    
    init() {
        fetchBadges()
    }
    
    func fetchBadges() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        let badgesRef = db.collection("users").document(uid).collection("badges")
        
        badgesRef.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Error fetching badges: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No badge documents found")
                return
            }
            
            let loadedBadges: [Badge] = documents.compactMap { doc in
                let data = doc.data()

                let tierString = data["tier"] as? String ?? "none"
                if let tier = BadgeTier(rawValue: tierString) {
                    let earnedMapRaw = data["timesEarnedByTier"] as? [String: Int] ?? [:]
                    let earnedMap: [BadgeTier: Int] = Dictionary(uniqueKeysWithValues:
                        earnedMapRaw.compactMap { (key, value) -> (BadgeTier, Int)? in
                            guard let tier = BadgeTier(rawValue: key) else { return nil }
                            return (tier, value)
                        }
                    )

                    let timestamp = data["lastAwarded"] as? Timestamp
                    let lastAwarded = timestamp?.dateValue()

                    return Badge(id: doc.documentID, tier: tier, timesEarnedByTier: earnedMap, lastAwarded: lastAwarded)
                } else {
                    return nil
                }
            }
            
            DispatchQueue.main.async {
                self.badges = loadedBadges
            }
        }
    }
}
