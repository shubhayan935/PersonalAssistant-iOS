//
//  ToneV1App.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 3/29/24.
//

import SwiftUI
import GoogleSignIn

@main
struct ToneV1App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(appUser: nil)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
