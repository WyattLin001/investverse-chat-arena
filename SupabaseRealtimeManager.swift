import Foundation
import Supabase

class SupabaseRealtimeManager: ObservableObject {
    static let shared = SupabaseRealtimeManager()
    
    private let client: SupabaseClient
    private var chatChannel: RealtimeChannel?
    
    private init() {
        // Replace with your actual Supabase URL and anon key
        let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
        let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
        
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    // MARK: - Real-time Chat Operations
    
    func subscribeToChat(groupId: String, onMessageReceived: @escaping (ChatMessageResponse) -> Void) {
        chatChannel = client.channel("chat:\(groupId)")
        
        chatChannel?.on("INSERT", table: "chat_messages") { message in
            if let payload = message.payload["new"] as? [String: Any],
               let messageData = try? JSONSerialization.data(withJSONObject: payload),
               let chatMessage = try? JSONDecoder().decode(ChatMessageResponse.self, from: messageData) {
                DispatchQueue.main.async {
                    onMessageReceived(chatMessage)
                }
            }
        }
        
        chatChannel?.subscribe()
    }
    
    func unsubscribeFromChat() {
        chatChannel?.unsubscribe()
        chatChannel = nil
    }
    
    func sendMessage(groupId: String, content: String, senderName: String, isInvestmentCommand: Bool = false) async throws {
        try await client
            .from("chat_messages")
            .insert([
                "group_id": groupId,
                "content": content,
                "sender_name": senderName,
                "is_investment_command": isInvestmentCommand,
                "created_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
    
    func fetchChatHistory(groupId: String) async throws -> [ChatMessageResponse] {
        let response: [ChatMessageResponse] = try await client
            .from("chat_messages")
            .select()
            .eq("group_id", value: groupId)
            .order("created_at", ascending: true)
            .limit(50)
            .execute()
            .value
        
        return response
    }
    
    // MARK: - Portfolio Operations
    
    func updatePortfolio(userId: String, symbol: String, action: String, amount: Double) async throws {
        try await client
            .from("portfolio_transactions")
            .insert([
                "user_id": userId,
                "symbol": symbol,
                "action": action,
                "amount": amount,
                "executed_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
    
    func fetchPortfolio(userId: String) async throws -> [PortfolioResponse] {
        let response: [PortfolioResponse] = try await client
            .from("user_portfolios")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response
    }
}

// MARK: - Response Models

struct ChatMessageResponse: Codable {
    let id: String
    let groupId: String
    let content: String
    let senderName: String
    let isInvestmentCommand: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId = "group_id"
        case content
        case senderName = "sender_name"
        case isInvestmentCommand = "is_investment_command"
        case createdAt = "created_at"
    }
}

struct PortfolioResponse: Codable {
    let id: String
    let userId: String
    let symbol: String
    let shares: Double
    let averagePrice: Double
    let currentValue: Double
    let returnRate: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case symbol
        case shares
        case averagePrice = "average_price"
        case currentValue = "current_value"
        case returnRate = "return_rate"
    }
}