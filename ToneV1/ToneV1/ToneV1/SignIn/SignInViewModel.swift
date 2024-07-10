//
//  SignInViewModel.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 3/29/24.
//

import Foundation
import GoogleSignIn

class SignInViewModel: ObservableObject {
    
    let signInApple = SignInApple()
    let signInGoogle = SignInGoogle()
    
    func isFormValid(email:String, password: String) -> Bool {
        guard email.isValidEmail(), password.count > 7 else {
            return false
        }
        return true
    }
    
    func registerNewUserWithEmail(email: String, password: String, name: String) async throws -> AppUser{
        if isFormValid(email: email, password: password){
            let newUser = try await AuthManager.shared.registerNewUserWithEmail(email: email, password: password, name: name)
            try await AuthManager.shared.registerUserProfile(userId: newUser.uid, name: name)
            return newUser
        } else {
            print("registration form is invalid")
            throw NSError()
        }
    }
    
    func signInWithEmail(email: String, password: String, name: String) async throws -> AppUser{
        if isFormValid(email: email, password: password){
            let newUser =  try await AuthManager.shared.signInWithEmail(email: email, password: password, name: "")
            return AppUser(uid: newUser.uid, email: newUser.email, name: newUser.name)
        } else {
            print("sign in form is invalid")
            throw NSError()
        }
    }
    
    func signInWithApple() async throws -> AppUser{
        let appleResult = try await signInApple.startSignInWithAppleFlow()
        return try await AuthManager.shared.signInWithApple(idToken: appleResult.idToken, nonce: appleResult.nonce)
    }
    
    func signInWithGoogle() async throws -> AppUser {
        let signInGoogle = SignInGoogle()
        let googleResult = try await signInGoogle.startSignInWithGoogleFlow()
        return try await AuthManager.shared.signInWithGoogle(idToken: googleResult.idToken)
    }
}

extension String {
    
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
}
