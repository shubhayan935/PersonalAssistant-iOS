//
//  AuthManager.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 3/29/24.
//

import Foundation
import Supabase

struct AppUser {
    let uid: String
    let email: String?
    var name: String
}



struct Automations {
    var title: String
}

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    let client = SupabaseClient(supabaseURL: URL(string: "https://nprgwzieebaphviuchba.supabase.co")!,
                                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wcmd3emllZWJhcGh2aXVjaGJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE0MzMxNTgsImV4cCI6MjAyNzAwOTE1OH0.t2218judh_d39AF2iKuS9NMMiiMCjIn7IdnEGLafqxk")
    
    func getCurrentSession() async throws  -> AppUser{
        let session = try await client.auth.session
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, name: "")
    }
    
    func registerNewUserWithEmail(email: String, password: String, name: String) async throws -> AppUser {
        let registrationAuthResponse = try await client.auth.signUp(email: email, password: password)
        guard let session = registrationAuthResponse.session else {
            print("No session when registering user")
            throw NSError()
        }
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, name: name)
    }
    
    func signInWithEmail(email: String, password: String, name: String) async throws -> AppUser {
        let session = try await client.auth.signIn(email: email, password: password)
        let userName = try await getUserName(userId: session.user.id.uuidString)
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, name: userName)
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws -> AppUser{
        let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .apple,
                                                                                 idToken: idToken,
                                                                                 nonce: nonce))
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, name: "")
    }
    
    func signInWithGoogle(idToken: String) async throws -> AppUser{
        let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken))
        print(session)
        print(session.user)
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, name: "")
        
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func registerUserProfile(userId: String, name: String) async throws {
        let toInsert = ["user_uid": userId, "name": name]
        let result = try await client.database
            .from("data")
            .insert(toInsert)
            .execute()
        
        print("Result status is:")
        print(result.status)
        // Handle the response, check for errors
    }
    
    // Adjust the function to return a String? representing the user's name
    struct UserData: Codable {
        let name: String?
    }
    
    func getUserName(userId: String) async throws -> String {
        let response = try await client.database
            .from("data")
            .select("name")
            .eq("user_uid", value: userId)
            .single()
            .execute()
        
        if let data = response.data as? Data {
            let decoder = JSONDecoder()
            if let userData = try? decoder.decode(UserData.self, from: data), let name = userData.name {
                return name
            }
        } else {
            print("No user data found")
        }
        
        // Fallback value if user name is not found or decoding fails
        return "Cutiepie"
    }
    

    func fetchAutomationTitle(userId: String) async throws -> String {
        let response = try await client.database
            .from("data")
            .select("action_title")
            .eq("user_uid", value: userId)
            .single()
            .execute()
        
        let result = String(String(data: response.data, encoding: .utf8) ?? "")
        
        let final = String(result.split(separator: "\"")[3])
        print("Titles")
        print(final)
        return final
    }
    
    
    func fetchChatHistoryTitle(userId: String) async throws -> String {
        let response = try await client.database
            .from("data")
            .select("chat_title")
            .eq("user_uid", value: userId)
            .single()
            .execute()
        
        let result = String(String(data: response.data, encoding: .utf8) ?? "")
        
        let final = String(result.split(separator: "\"")[3])
        print("Chat Titles from function")
        print(final)
        return final
    }
    
    func fetchConversationHistory(userId:String) async throws {
        let response = try await client.database.from("chat_history")
            .select("conversation_history")
            .eq("user_uid", value: userId)
            .execute()
            .value
        
        print("Conversation History")
        print(response)
    }
    
}
