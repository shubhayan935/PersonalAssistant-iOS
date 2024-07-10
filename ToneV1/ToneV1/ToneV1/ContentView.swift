//
//  ContentView.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 3/29/24.
//

import SwiftUI
import CoreData

struct ContentView: View{
    @State var appUser: AppUser? = nil
    @State var automations: Automations? = nil
    
    var body: some View {
        ZStack {
            if let appUser = appUser {
                    HomeView(appUser: $appUser, automations: $automations)
            } else {
                SignInView(appUser: $appUser)
            }
        }
        .onAppear {
            Task {
                self.appUser = try await AuthManager.shared.getCurrentSession()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(appUser: nil)
    }
}
