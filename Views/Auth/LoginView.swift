//
//  LoginView.swift
//  FitHub
//
//  Created by brandon metz on 6/21/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isCreatingAccount = false

    var body: some View {
        VStack(spacing: 24) {
            Text("FitHub")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = viewModel.authError {
                Text(error)
                    .foregroundColor(.red)
            }

            Button(viewModel.isLoading ? "Loading..." : isCreatingAccount ? "Sign Up" : "Log In") {
                if isCreatingAccount {
                    viewModel.signUp(email: email, password: password) {}
                } else {
                    viewModel.logIn(email: email, password: password) {}
                }
            }
            .disabled(viewModel.isLoading)

            Button(isCreatingAccount ? "Already have an account? Log In" : "Don't have an account? Sign Up") {
                isCreatingAccount.toggle()
                viewModel.authError = nil
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
