//
//  ProfileViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/22/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var authListener: AuthStateDidChangeListenerHandle?

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    private var docRef: DocumentReference? {
        guard let uid = userId else { return nil }
        return db.collection("users")
                 .document(uid)
                 .collection("meta")
                 .document("profile")
    }

    init() {
        // Listen for auth state changes
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if user == nil {
                    // Clear profile when signed out
                    self.profile = nil
                } else {
                    // Fetch profile for the new user
                    self.fetchProfile()
                }
            }
        }
    }

    deinit {
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func fetchProfile() {
        guard let ref = docRef else { return }
        isLoading = true
        ref.getDocument(as: UserProfile.self) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let up):
                    self.profile = up
                case .failure(let error):
                    // If no profile exists yet, leave profile = nil
                    if (error as NSError).code != FirestoreErrorCode.notFound.rawValue {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func saveProfile(_ profile: UserProfile, completion: @escaping (Bool) -> Void) {
        guard let ref = docRef, let uid = userId else { return }
        isLoading = true
        do {
            // 1️⃣ Save profile under users/{uid}/meta/profile
            try ref.setData(from: profile) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                        completion(false)
                        return
                    }

                    // 2️⃣ Merge dailyCalorieAllowance into root users/{uid}
                    let rootRef = self.db.collection("users").document(uid)
                    rootRef.setData(["dailyCalorieAllowance": profile.calorieTarget], merge: true) { mergeError in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            if let mergeError = mergeError {
                                self.errorMessage = mergeError.localizedDescription
                                completion(false)
                                return
                            }
                            // 3️⃣ Update in-memory profile
                            self.profile = profile
                            completion(true)
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
}
