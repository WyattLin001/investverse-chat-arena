import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    private let client: SupabaseClient
    
    private init() {
        // Replace with your actual Supabase URL and anon key
        let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
        let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
        
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    
    // MARK: - Group Data Operations
    
    func fetchGroups() async throws -> [InvestmentGroup] {
        let response: [GroupResponse] = try await client
            .from("investment_groups")
            .select()
            .execute()
            .value
        
        return response.map { groupResponse in
            InvestmentGroup(
                name: groupResponse.name,
                host: groupResponse.host,
                returnRate: groupResponse.returnRate,
                entryFee: groupResponse.entryFee,
                memberCount: groupResponse.memberCount,
                category: groupResponse.category
            )
        }
    }
    
    func fetchWeeklyRankings() async throws -> [RankingItem] {
        let response: [RankingResponse] = try await client
            .from("weekly_rankings")
            .select()
            .order("return_rate", ascending: false)
            .limit(3)
            .execute()
            .value
        
        return response.map { rankingResponse in
            RankingItem(
                name: rankingResponse.name,
                returnRate: rankingResponse.returnRate
            )
        }
    }
    
    func joinGroup(groupId: String, userId: String) async throws {
        try await client
            .from("group_members")
            .insert([
                "group_id": groupId,
                "user_id": userId,
                "joined_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
    }
}

// MARK: - Response Models

struct GroupResponse: Codable {
    let id: String
    let name: String
    let host: String
    let returnRate: Double
    let entryFee: String
    let memberCount: Int
    let category: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, host, category
        case returnRate = "return_rate"
        case entryFee = "entry_fee"
        case memberCount = "member_count"
    }
}

struct RankingResponse: Codable {
    let id: String
    let name: String
    let returnRate: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case returnRate = "return_rate"
    }
}