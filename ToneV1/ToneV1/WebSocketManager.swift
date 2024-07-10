//
//  WebSocketManager.swift
//  ToneV1
//
//  Created by Shubhayan Srivastava on 4/8/24.
//

import Foundation

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    @Published var receivedMessages: [String] = []

    func connect() {
        guard let url = URL(string: "ws://localhost:5000") else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }

    func sendMessage(_ message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("WebSocket sending error: \(error)")
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("WebSocket receiving error: \(error)")
            case .success(.string(let text)):
                DispatchQueue.main.async {
                    self?.receivedMessages.append(text)
                }
                self?.receiveMessage()
            default:
                break
            }
        }
    }
}
