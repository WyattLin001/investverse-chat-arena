import SwiftUI
import Supabase

struct InfoView: View {
    @StateObject private var viewModel = InfoViewModel()
    @State private var searchText = ""
    @State private var selectedTab = 2
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Navigation Bar
                InfoNavigationBar(searchText: $searchText)
                
                // Article List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredArticles) { article in
                            ArticleCardView(article: article) {
                                viewModel.selectedArticle = article
                                viewModel.showArticleDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .background(Color(hex: "F5F5F5"))
                
                // Recommended Authors Section
                RecommendedAuthorsView(authors: viewModel.recommendedAuthors)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showArticleDetail) {
            if let article = viewModel.selectedArticle {
                ArticleDetailView(article: article, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadArticles()
        }
    }
}

struct InfoNavigationBar: View {
    @Binding var searchText: String
    @State private var showSearch = false
    
    var body: some View {
        HStack {
            Text("投資資訊")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSearch.toggle()
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
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
        
        if showSearch {
            SearchBar(text: $searchText)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: showSearch)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("搜尋文章或作者...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button("清除") {
                    text = ""
                }
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "00B900"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
    }
}

struct ArticleCardView: View {
    let article: Article
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Category and Read Time
                HStack {
                    Text("免費")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "00B900"))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(article.readTime)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                // Title
                Text(article.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                // Summary
                Text(article.summary)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Author and Interaction
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(article.author)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Button(action: {
                                // Handle subscribe
                            }) {
                                Text(article.isSubscribed ? "已訂閱" : "訂閱")
                                    .font(.system(size: 10))
                                    .foregroundColor(article.isSubscribed ? .white : Color(hex: "00B900"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(article.isSubscribed ? Color(hex: "00B900") : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(hex: "00B900"), lineWidth: 1)
                                    )
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                            Text("\(article.likes)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text("\(article.comments)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .frame(height: 100)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ArticleDetailView: View {
    let article: Article
    @ObservedObject var viewModel: InfoViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isLiked = false
    @State private var showComments = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Article Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(article.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(article.author)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text("發布於 \(article.publishDate, formatter: dateFormatter)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Divider()
                    
                    // Article Content
                    Text(article.fullContent)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                    
                    // Creator Bonus Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("創作者獎勵")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "FD7E14"))
                            
                            Text("每 100 個讚可獲得 100 NTD 獎勵")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("目前獎勵: \(article.likes / 100 * 100) NTD")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "00B900"))
                        }
                        .padding(12)
                        .background(Color(hex: "FD7E14").opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Interaction Area
                    HStack(spacing: 24) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isLiked.toggle()
                                viewModel.toggleLike(for: article)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 20))
                                    .foregroundColor(isLiked ? .red : .gray)
                                    .scaleEffect(isLiked ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
                                
                                Text("\(article.likes + (isLiked ? 1 : 0))")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Button(action: {
                            showComments = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                                
                                Text("\(article.comments)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Share functionality
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("關閉") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("收藏") {
                    // Handle bookmark
                }
            )
        }
        .sheet(isPresented: $showComments) {
            CommentsView(article: article)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter
    }
}

struct CommentsView: View {
    let article: Article
    @Environment(\.presentationMode) var presentationMode
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Comments list would go here
                Text("評論功能開發中...")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Comment input
                HStack {
                    TextField("寫下你的想法...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("發送") {
                        // Handle comment submission
                        newComment = ""
                    }
                    .disabled(newComment.isEmpty)
                }
                .padding()
            }
            .navigationTitle("評論")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct RecommendedAuthorsView: View {
    let authors: [Author]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("推薦作者")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(authors) { author in
                        AuthorCardView(author: author)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color.white)
    }
}

struct AuthorCardView: View {
    let author: Author
    @State private var isFollowing = false
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                )
            
            Text(author.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFollowing.toggle()
                }
            }) {
                Text(isFollowing ? "已關注" : "關注")
                    .font(.system(size: 10))
                    .foregroundColor(isFollowing ? .white : Color(hex: "00B900"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(isFollowing ? Color(hex: "00B900") : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "00B900"), lineWidth: 1)
                    )
                    .cornerRadius(12)
            }
        }
        .frame(width: 80)
    }
}

// MARK: - Data Models

struct Article: Identifiable, Codable {
    let id = UUID()
    let title: String
    let author: String
    let summary: String
    let fullContent: String
    let likes: Int
    let comments: Int
    let readTime: String
    let category: String
    let isSubscribed: Bool
    let publishDate: Date
    
    init(title: String, author: String, summary: String, fullContent: String, likes: Int, comments: Int, readTime: String, category: String, isSubscribed: Bool = false) {
        self.title = title
        self.author = author
        self.summary = summary
        self.fullContent = fullContent
        self.likes = likes
        self.comments = comments
        self.readTime = readTime
        self.category = category
        self.isSubscribed = isSubscribed
        self.publishDate = Date()
    }
}

struct Author: Identifiable {
    let id = UUID()
    let name: String
    let followers: Int
    let articles: Int
}

// MARK: - View Model

class InfoViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var recommendedAuthors: [Author] = []
    @Published var selectedArticle: Article?
    @Published var showArticleDetail = false
    @Published var searchText = ""
    
    var filteredArticles: [Article] {
        if searchText.isEmpty {
            return articles
        } else {
            return articles.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func loadArticles() {
        articles = [
            Article(
                title: "AI 股票投資策略：如何在科技革命中獲利",
                author: "投資分析師王小明",
                summary: "探討人工智慧對股市的影響，以及如何選擇相關投資標的。本文深入分析當前AI產業趨勢，提供實用的投資建議。",
                fullContent: """
                人工智慧正在改變世界，也在重塑投資市場。作為投資者，我們需要了解這個趨勢並從中獲利。
                
                首先，讓我們看看AI產業的現狀。目前，AI技術在各個領域都有廣泛應用，從自動駕駛到醫療診斷，從金融分析到內容創作。這些應用正在創造巨大的市場價值。
                
                投資AI股票的策略：
                1. 關注核心技術公司：如NVIDIA、AMD等晶片製造商
                2. 投資應用層公司：如Google、Microsoft等科技巨頭
                3. 關注新興AI公司：尋找具有創新技術的初創企業
                
                風險控制也很重要。AI產業雖然前景光明，但也存在技術風險、監管風險等。建議投資者分散投資，不要把所有資金都投入AI股票。
                
                總結來說，AI投資是一個長期趨勢，但需要謹慎選擇標的和控制風險。
                """,
                likes: 245,
                comments: 67,
                readTime: "5 分鐘",
                category: "科技股"
            ),
            Article(
                title: "綠能轉型：太陽能股票投資機會分析",
                author: "環保投資專家Lisa",
                summary: "全球綠能政策推動下，太陽能產業迎來黃金發展期。分析主要太陽能公司的投資價值和未來前景。",
                fullContent: """
                隨著全球對氣候變化的關注日益增加，綠能產業正迎來前所未有的發展機遇。太陽能作為最重要的可再生能源之一，其投資價值值得深入探討。
                
                太陽能產業的發展趨勢：
                1. 技術進步：太陽能電池效率不斷提升，成本持續下降
                2. 政策支持：各國政府推出綠能補貼和稅收優惠
                3. 市場需求：企業和個人對清潔能源的需求快速增長
                
                主要投資標的分析：
                - 太陽能設備製造商：如First Solar、SunPower
                - 太陽能項目開發商：如NextEra Energy、Brookfield Renewable
                - 太陽能材料供應商：如Enphase Energy、SolarEdge
                
                投資建議：
                太陽能股票具有長期投資價值，但短期可能面臨政策變化和技術競爭的風險。建議投資者採用定期定額的方式投資，分散風險。
                """,
                likes: 189,
                comments: 43,
                readTime: "7 分鐘",
                category: "綠能",
                isSubscribed: true
            ),
            Article(
                title: "短線交易心法：如何在波動市場中生存",
                author: "交易員Kevin",
                summary: "分享短線交易的技巧與風險控制策略，適合積極投資者參考。包含實戰案例和心理建設。",
                fullContent: """
                短線交易是一門藝術，也是一門科學。在瞬息萬變的市場中，如何保持冷靜並做出正確決策，是每個短線交易者必須掌握的技能。
                
                短線交易的基本原則：
                1. 嚴格止損：設定明確的止損點，絕不心存僥倖
                2. 快進快出：不要戀戰，獲利了結要果斷
                3. 資金管理：每次交易的風險不超過總資金的2%
                
                技術分析要點：
                - 支撐阻力位：識別關鍵價位
                - 成交量分析：確認價格走勢的有效性
                - 趨勢線：判斷市場方向
                
                心理建設：
                短線交易最大的敵人是自己的情緒。貪婪和恐懼會讓交易者做出錯誤決策。建議制定交易計劃並嚴格執行，不要因為一時的得失而改變策略。
                
                風險提醒：
                短線交易風險極高，不適合所有投資者。建議新手先從模擬交易開始，積累經驗後再投入真實資金。
                """,
                likes: 356,
                comments: 89,
                readTime: "4 分鐘",
                category: "短期投機"
            )
        ]
        
        recommendedAuthors = [
            Author(name: "投資大師Tom", followers: 15420, articles: 156),
            Author(name: "環保專家Lisa", followers: 8930, articles: 89),
            Author(name: "交易員Kevin", followers: 23450, articles: 234)
        ]
    }
    
    func toggleLike(for article: Article) {
        if let index = articles.firstIndex(where: { $0.id == article.id }) {
            // Update likes count in Supabase
            Task {
                await updateLikesInSupabase(articleId: article.id.uuidString, increment: true)
            }
        }
    }
    
    private func updateLikesInSupabase(articleId: String, increment: Bool) async {
        // Implementation for updating likes in Supabase
        // This would also calculate and update creator bonus
    }
}

#Preview {
    InfoView()
}