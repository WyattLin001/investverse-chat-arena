import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Navigation Bar
                TopNavigationBar(ntwBalance: viewModel.ntwBalance)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Weekly Ranking Section
                        WeeklyRankingView(rankings: viewModel.weeklyRankings)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        // Group List Section
                        GroupListView(groups: viewModel.groups) { group in
                            // Navigate to Wallet page when Join Group is tapped
                            selectedTab = 3
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                .background(Color(hex: "F5F5F5"))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct TopNavigationBar: View {
    let ntwBalance: Int
    
    var body: some View {
        HStack {
            // NTD Balance
            Text("NTD \(ntwBalance.formatted())")
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "00B900"))
            
            Spacer()
            
            HStack(spacing: 16) {
                // Notification Button
                Button(action: {
                    // Handle notification tap
                }) {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
                
                // Search Button
                Button(action: {
                    // Handle search tap
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
}

struct WeeklyRankingView: View {
    let rankings: [RankingItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本週排行榜")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(Array(rankings.enumerated()), id: \.element.id) { index, ranking in
                    RankingRowView(ranking: ranking, position: index + 1)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .frame(height: 100)
    }
}

struct RankingRowView: View {
    let ranking: RankingItem
    let position: Int
    @State private var animateNumber = false
    
    private var badgeColor: Color {
        switch position {
        case 1: return Color(hex: "FFD700") // Gold
        case 2: return Color(hex: "C0C0C0") // Silver
        case 3: return Color(hex: "CD7F32") // Bronze
        default: return .gray
        }
    }
    
    private var badgeEmoji: String {
        switch position {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    var body: some View {
        HStack {
            Text(badgeEmoji)
                .font(.system(size: 16))
            
            Text(ranking.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("+\(ranking.returnRate, specifier: "%.1f")%")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "00B900"))
                .scaleEffect(animateNumber ? 1.0 : 0.8)
                .opacity(animateNumber ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(Double(position) * 0.1), value: animateNumber)
        }
        .onAppear {
            animateNumber = true
        }
    }
}

struct GroupListView: View {
    let groups: [InvestmentGroup]
    let onJoinGroup: (InvestmentGroup) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("推薦群組")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(groups) { group in
                    GroupCardView(group: group, onJoinTapped: {
                        onJoinGroup(group)
                    })
                }
            }
        }
    }
}

struct GroupCardView: View {
    let group: InvestmentGroup
    let onJoinTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("主持人：\(group.host)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("+\(group.returnRate, specifier: "%.1f")%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "00B900"))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "00B900").opacity(0.1))
                        .cornerRadius(4)
                    
                    Text(group.entryFee)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "person.2")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("\(group.memberCount)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onJoinTapped) {
                Text("加入群組")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "FD7E14"))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .frame(height: 80)
    }
}

// MARK: - Data Models

struct RankingItem: Identifiable {
    let id = UUID()
    let name: String
    let returnRate: Double
}

struct InvestmentGroup: Identifiable {
    let id = UUID()
    let name: String
    let host: String
    let returnRate: Double
    let entryFee: String
    let memberCount: Int
    let category: String
}

// MARK: - View Model

class HomeViewModel: ObservableObject {
    @Published var ntwBalance: Int = 5000
    @Published var weeklyRankings: [RankingItem] = []
    @Published var groups: [InvestmentGroup] = []
    
    func loadData() {
        // Simulate loading data from Supabase
        loadWeeklyRankings()
        loadGroups()
    }
    
    private func loadWeeklyRankings() {
        weeklyRankings = [
            RankingItem(name: "投資大師Tom", returnRate: 18.5),
            RankingItem(name: "環保投資者Lisa", returnRate: 12.3),
            RankingItem(name: "快手Kevin", returnRate: 25.7)
        ]
    }
    
    private func loadGroups() {
        groups = [
            InvestmentGroup(
                name: "科技股挑戰賽",
                host: "投資大師Tom",
                returnRate: 18.5,
                entryFee: "2 花束 (200 NTD)",
                memberCount: 156,
                category: "科技股"
            ),
            InvestmentGroup(
                name: "綠能未來",
                host: "環保投資者Lisa",
                returnRate: 12.3,
                entryFee: "1 火箭 (1000 NTD)",
                memberCount: 89,
                category: "綠能"
            ),
            InvestmentGroup(
                name: "短線交易王",
                host: "快手Kevin",
                returnRate: 25.7,
                entryFee: "5 花束 (500 NTD)",
                memberCount: 234,
                category: "短期投機"
            )
        ]
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}