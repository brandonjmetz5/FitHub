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

    private var db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    private var docRef: DocumentReference? {
        guard let uid = userId else { return nil }
        return db.collection("users").document(uid).collection("meta").document("profile")
    }

    init() {
        fetchProfile()
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
                    // If no profile exists yet, we simply leave profile = nil
                    if (error as NSError).code != FirestoreErrorCode.notFound.rawValue {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func saveProfile(_ profile: UserProfile, completion: @escaping (Bool) -> Void) {
        guard let ref = docRef else { return }
        do {
            try ref.setData(from: profile) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    } else {
                        self.profile = profile
                        completion(true)
                    }
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
            completion(false)
        }
    }
}
