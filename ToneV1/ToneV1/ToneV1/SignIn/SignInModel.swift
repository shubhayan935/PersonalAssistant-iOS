//
//  SignInModel.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 3/29/24.
//

import Foundation

class SignInViewModel: ObservableObject {
    
    let signInApple = SignInApple()
    
    func signInWithApple() async throws -> AppUser{
        let appleResult = try await signInApple.startSignInWithAppleFlow()
        return try await AuthManager.shared.signInWithApple(idToken: appleResult.idToken, nonce: appleResult.nonce)
    }
}
