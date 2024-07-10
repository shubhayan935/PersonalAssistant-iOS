//
//  ChatView.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 3/31/24.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id: Int
    let message: String
    let isUser: Bool // true for user messages, false for chatbot messages
}

struct ChatView: View {
    @Binding var appUser: AppUser?
    @Binding var chatTitle: String
    @State private var showChat = false
    @State private var newMessage = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(id: 0, message: "Hello! How can I assist you today?", isUser: false)
        // You can add more dummy data for the chatbot messages here.
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Black background for the entire screen

            VStack {
                
                Rectangle()
                    .fill(Color.white.opacity(0.7))
                    .frame(height: 5)
                    .frame(maxWidth: 30)
                    .padding(.horizontal)
                    .padding(.top, 8)

                
                HStack {
                    Text(chatTitle)
                        .font(.title2)
                        .foregroundColor(.white)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Text input area
                HStack {
                    TextField("Type a message...", text: $newMessage)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(12)
                        .background(Color.white.opacity(0.1)) // Slightly transparent background for the text field
                        .cornerRadius(20)
                        .foregroundColor(.white)
                    
                    Spacer()

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                            .background(Color.black)
                            .clipShape(Circle())
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 2) // This adds the white border
                            )
                    }
                    .padding(.leading, 10)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true) // Use this if you want to hide the navigation bar
    }

    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let userMessage = ChatMessage(id: messages.count, message: newMessage, isUser: true)
        messages.append(userMessage)
        
        let url = URL(string: "http://127.0.0.1:5000/message")! // Your Flask server URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["message": newMessage, "title": chatTitle, "userId": appUser?.uid as Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let responseMessage = String(data: data, encoding: .utf8) ?? "Server could not be reached"
                print(responseMessage)
                
                DispatchQueue.main.async {
                    let botMessage = ChatMessage(id: messages.count, message: responseMessage, isUser: false)
                    messages.append(botMessage)
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }.resume()
        
        newMessage = ""
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.message)
                    .padding()
                    .background(Color.blue) // User messages in blue
                    .cornerRadius(25)
                    .foregroundColor(.white)
                    .padding(.leading, 100) // To keep the user messages to the right
                    .padding(.top, 20)
            } else {
                Text(message.message)
                    .padding()
                    .background(Color.gray.opacity(0.3)) // Chatbot messages in gray
                    .cornerRadius(25)
                    .foregroundColor(.white)
                    .padding(.trailing, 100) // To keep the chatbot messages to the left
                    .padding(.top, 20)
                Spacer()
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(appUser: .constant(.init(uid: "1234", email: "myemail@tone.com", name: "User")),
                 chatTitle: .constant("Sample Chat"))
    }
}
