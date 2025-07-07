import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .foregroundColor(selectedTab == 0 ? Color(hex: "00B900") : .gray)
                    Text("主頁")
                        .font(.system(size: 12))
                }
                .tag(0)
            
            ChatView()
                .tabItem {
                    Image(systemName: "bubble.left")
                    Text("聊天")
                        .font(.system(size: 12))
                }
                .tag(1)
            
            InfoView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("資訊")
                        .font(.system(size: 12))
                }
                .tag(2)
            
            WalletView()
                .tabItem {
                    Image(systemName: "wallet.pass")
                    Text("錢包")
                        .font(.system(size: 12))
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("設定")
                        .font(.system(size: 12))
                }
                .tag(4)
        }
        .accentColor(Color(hex: "00B900"))
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}