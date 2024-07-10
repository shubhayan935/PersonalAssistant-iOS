//
//  SignInGoogle.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 3/29/24.
//

import Foundation
import GoogleSignIn
import SwiftUI

struct SignInGoogleResult {
    let idToken: String
}

class SignInGoogle {
    
    func startSignInWithGoogleFlow() async throws -> SignInGoogleResult {
        try await withCheckedThrowingContinuation({ [weak self] continuation in
            self?.signInWithGoogleFlow { result in
                continuation.resume(with: result)
            
        }})
    }
    
    func signInWithGoogleFlow(completion: @escaping (Result<SignInGoogleResult, Error>) -> Void){
        guard let topVC = UIApplication.getTopViewController() else {
            completion(.failure(NSError()))
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { signInResult, error in
            guard let user = signInResult?.user, let idToken = user.idToken else {
                completion(.failure(NSError()))
              return
            }
            completion(.success(.init(idToken: idToken.tokenString)))
          }
    }
    
}
