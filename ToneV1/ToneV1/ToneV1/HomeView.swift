//
//  HomeView.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 3/29/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @Binding var appUser: AppUser?
    @Binding var automations: Automations?
    @State private var selectedTab = "Home" 
    @State private var chatTitles: [String] = []
    @State private var automationTitles: [String] = []
    @State private var showChat = false
    @State private var chatTitle: String = ""
    @State private var expandedCardID: Int? = nil

    
    
    var body: some View {
        
        if let appUser = appUser {
            NavigationView {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    
                    ScrollView {
                        VStack (alignment: .leading, spacing: 20){
                            
                            greetingSection
                                .padding([.leading, .trailing, .top], 20)
                            
                            newChat
                            // Sections
                            yourAutomations
                            chatHistory
                            promptLibrary
                        }
                        .blur(radius: selectedTab == "Search" ? 30 : 0)
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            BottomBarButton(imageName: "house", text: "Home", selectedTab: $selectedTab)
                            Spacer()
                            BottomBarButton(imageName: "magnifyingglass", text: "Search", selectedTab: $selectedTab)
                            Spacer()
                        }
                        .frame(height: 80)
                        .frame(maxWidth: 250)
                        .background(BlurView(style: .systemThinMaterialDark))
                        .clipShape(Capsule())
                        .padding()
                        .shadow(radius: 10)
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    func loadTitlesAndSubtitles() async {
        do {
            try await AuthManager.shared.fetchConversationHistory(userId: appUser?.uid ?? "1234")
            let AutomationTitlesString = try await AuthManager.shared.fetchAutomationTitle(userId: appUser?.uid ?? "1234")
            
            // Splitting the titles and subtitles into arrays
            automationTitles = AutomationTitlesString.components(separatedBy: " | ")
            
            let ChatTitlesString = try await AuthManager.shared.fetchChatHistoryTitle(userId: appUser?.uid ?? "1234")
            
            // Splitting the titles and subtitles into arrays
            chatTitles = ChatTitlesString.components(separatedBy: " | ")
        } catch {
            print("Error fetching titles and subtitles")
        }
    }
    
    var bottomBar: some View {
         HStack {
             Spacer()
             BottomBarButton(imageName: "house", text: "Home", selectedTab: $selectedTab)
             Spacer()
             BottomBarButton(imageName: "magnifyingglass", text: "Search", selectedTab: $selectedTab)
             Spacer()
         }
         .frame(maxWidth: .infinity)
         .frame(height: 88)
         .background(BlurView(style: .systemThinMaterialDark))
         .clipShape(Capsule())
         .padding()
         .shadow(radius: 10)
         .edgesIgnoringSafeArea(.bottom)
     }
    
    var greetingSection: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome to Tone,")
                        .foregroundColor(.gray)
                    Text(appUser?.name ?? "Guest")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
                Button {
                    Task{
                        do{
                            print("Signing out")
                            try await AuthManager.shared.signOut()
                            self.appUser = nil
                        } catch {
                            print("Unable to Sign Out")
                        }
                    }
                } label: {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
        }
    
    var newChat: some View {
        Button {
            chatTitle = "New Chat"
            showChat = true
        } label: {
            Text("New Chat")
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .white.opacity(0.8), radius: 20, x: 0, y: 4)
                .padding(.horizontal, 20)
                .sheet(isPresented: $showChat) {
                    ChatView(appUser: $appUser, chatTitle: $chatTitle)
                }
        }
    }
    
    var chatHistory: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Chat history")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    .padding(.top, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // Replace with actual data and make each item a NavigationLink if needed
                        ForEach(Array(zip(chatTitles.indices, chatTitles)), id: \.0) { index, title in
                            HistoryCardView(title: title){
                                self.chatTitle = title
                                self.showChat = true
                            }
                        }
                    }
                    .padding(.leading, 20)
                }
            }
        }
    
    var yourAutomations: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Automations")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.leading, 20)
                .padding(.top, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Array(zip(automationTitles.indices, automationTitles)), id: \.0) { index, title in
                        yourAutomationsView(title: title,
                                            isExpanded: .init(
                                                get: { self.expandedCardID == index },
                                                set: { _ in self.expandedCardID = (self.expandedCardID == index ? nil : index) }
                                            )
                                        )
                    }
                }
                .padding(.leading, 20)
            }
            .onAppear {
                Task {
                    await loadTitlesAndSubtitles()
                }
            }
        }
    }
    
    var promptLibrary: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Topics you might be interested in")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.leading, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(["Sales", "SEO", "Midjourney", "Marketing", "Design", "Email"], id: \.self) { category in
                        CategoryView(category: category)
                    }
                }
                .padding(.leading, 20)
            }
        }
    }
}

struct BottomBarButton: View {
    var imageName: String
    var text: String
    @Binding var selectedTab: String

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(selectedTab == text ? .white : .gray)
            Text(text)
                .font(.caption)
                .foregroundColor(selectedTab == text ? .white : .gray)
        }
        .padding(.vertical, 8)
        .onTapGesture {
            selectedTab = text
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct HistoryCardView: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 5)
        }
        .onTapGesture(perform: action)
        .padding()
        .frame(width: 250, height: 120)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
    }
}

struct yourAutomationsView: View {
    var title: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 5)
        }
        .padding()
        .frame(width: 250, height: 120)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(10)
        .onTapGesture {
            withAnimation {
                self.isExpanded.toggle() // Toggle the expansion state
            }
        }
    }
}

struct SectionView: View {
    var title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct CategoryView: View {
    var category: String
    
    var body: some View {
        Text(category)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
    }
}

extension UIColor {
   convenience init(hexString: String, alpha: CGFloat = 1.0) {
       var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

       if hexFormatted.hasPrefix("#") {
           hexFormatted = String(hexFormatted.dropFirst())
       }

       assert(hexFormatted.count == 6, "Invalid hex code used.")

       var rgbValue: UInt64 = 0
       Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

       let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
       let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
       let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

       self.init(red: red, green: green, blue: blue, alpha: alpha)
   }
}

#Preview {
    HomeView(appUser: .constant(.init(uid: "1234", email: "myemail@tone.com", name: "User")), 
             automations: .constant(.init(title: "Place")))
}


