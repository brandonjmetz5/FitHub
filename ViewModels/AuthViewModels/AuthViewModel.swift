//
//  AuthViewModel.swift
//  FitHub
//
//  Created by brandon metz on 6/21/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var authError: String?

    init() {
        self.user = Auth.auth().currentUser
    }

    var isLoggedIn: Bool {
        return user != nil
    }

    func signUp(email: String, password: String, completion: @escaping () -> Void) {
        isLoading = true
        authError = nil

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.authError = error.localizedDescription
                    return
                }

                guard let newUser = result?.user else { return }
                self.user = newUser

                let db = Firestore.firestore()
                db.collection("users").document(newUser.uid).setData([
                    "email": newUser.email ?? "",
                    "createdAt": Timestamp()
                ])

                completion()
            }
        }
    }

    func logIn(email: String, password: String, completion: @escaping () -> Void) {
        isLoading = true
        authError = nil

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.authError = error.localizedDescription
                    return
                }

                self.user = result?.user
                completion()
            }
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.authError = error.localizedDescription
        }
    }
}
