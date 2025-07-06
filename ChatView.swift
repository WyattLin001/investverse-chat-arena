import SwiftUI
import Supabase

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var showInvestmentPanel = false
    @State private var selectedTab = 1
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Navigation Bar
                ChatNavigationBar(
                    groupName: viewModel.currentGroup?.name ?? "群組聊天",
                    hostName: viewModel.currentGroup?.host ?? "",
                    memberCount: viewModel.currentGroup?.memberCount ?? 0,
                    onSendGift: {
                        selectedTab = 3 // Navigate to Wallet
                    }
                )
                
                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(Color(hex: "F5F5F5"))
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Investment Panel (Host Only)
                if viewModel.isHost && showInvestmentPanel {
                    InvestmentPanelView(viewModel: viewModel.investmentViewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showInvestmentPanel)
                }
                
                // Bottom Input Area
                ChatInputView(
                    messageText: $messageText,
                    isHost: viewModel.isHost,
                    showInvestmentPanel: $showInvestmentPanel,
                    onSendMessage: {
                        viewModel.sendMessage(messageText)
                        messageText = ""
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadChatData()
            viewModel.startListeningForMessages()
        }
        .onDisappear {
            viewModel.stopListeningForMessages()
        }
    }
}

struct ChatNavigationBar: View {
    let groupName: String
    let hostName: String
    let memberCount: Int
    let onSendGift: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(groupName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("主持人：\(hostName)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "person.2")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("\(memberCount)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onSendGift) {
                Image(systemName: "gift")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "00B900"))
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

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isOwn {
                Spacer()
                messageBubble
                    .background(Color(hex: "00B900"))
                    .foregroundColor(.white)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    if !message.isOwn {
                        HStack {
                            Text(message.senderName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                            
                            if message.isHost {
                                Text("主持人")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: "00B900"))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    messageBubble
                        .background(message.isInvestmentCommand ? Color(hex: "007BFF") : Color.white)
                        .foregroundColor(message.isInvestmentCommand ? .white : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: message.isInvestmentCommand ? 0 : 1)
                        )
                }
                Spacer()
            }
        }
    }
    
    private var messageBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.content)
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                Text(message.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(message.isOwn ? .white.opacity(0.7) : .secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .cornerRadius(12)
    }
}

struct ChatInputView: View {
    @Binding var messageText: String
    let isHost: Bool
    @Binding var showInvestmentPanel: Bool
    let onSendMessage: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.3))
            
            HStack(spacing: 12) {
                if isHost {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showInvestmentPanel.toggle()
                        }
                    }) {
                        Image(systemName: showInvestmentPanel ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "007BFF"))
                    }
                }
                
                TextField("輸入訊息...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSendMessage()
                        }
                    }
                
                Button(action: {
                    if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSendMessage()
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(hex: "00B900"))
                        .cornerRadius(16)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
        }
        .frame(height: 40)
    }
}

struct InvestmentPanelView: View {
    @ObservedObject var viewModel: InvestmentViewModel
    @State private var stockSymbol = ""
    @State private var amount = ""
    @State private var selectedAction = "Buy"
    
    private let actions = ["Buy", "Sell"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Trading Controls
            HStack(spacing: 12) {
                Picker("Action", selection: $selectedAction) {
                    ForEach(actions, id: \.self) { action in
                        Text(action == "Buy" ? "買入" : "賣出").tag(action)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 100)
                
                TextField("股票代號", text: $stockSymbol)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                
                TextField("金額", text: $amount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Button(action: {
                    executeTradeCommand()
                }) {
                    Text("執行")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "007BFF"))
                        .cornerRadius(6)
                }
                .disabled(stockSymbol.isEmpty || amount.isEmpty)
            }
            
            // Portfolio Overview
            VStack(spacing: 8) {
                HStack {
                    Text("投資組合")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("總回報: +\(viewModel.totalReturn, specifier: "%.1f")%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "00B900"))
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.portfolio) { holding in
                            PortfolioItemView(holding: holding)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
    }
    
    private func executeTradeCommand() {
        guard let amountValue = Double(amount) else { return }
        
        let command = "[\(selectedAction == "Buy" ? "買入" : "賣出")] \(stockSymbol.uppercased()) \(formatAmount(amountValue))"
        
        // Send trade command as chat message
        viewModel.executeTradeCommand(
            action: selectedAction,
            symbol: stockSymbol.uppercased(),
            amount: amountValue,
            commandText: command
        )
        
        // Clear inputs
        stockSymbol = ""
        amount = ""
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 1000000 {
            return String(format: "%.0fM", amount / 1000000)
        } else if amount >= 1000 {
            return String(format: "%.0fK", amount / 1000)
        } else {
            return String(format: "%.0f", amount)
        }
    }
}

struct PortfolioItemView: View {
    let holding: PortfolioHolding
    
    var body: some View {
        VStack(spacing: 4) {
            Text(holding.symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("\(holding.percentage, specifier: "%.1f")%")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            
            Text(holding.returnRate >= 0 ? "+\(holding.returnRate, specifier: "%.1f")%" : "\(holding.returnRate, specifier: "%.1f")%")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(holding.returnRate >= 0 ? Color(hex: "00B900") : .red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Data Models

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let senderName: String
    let isOwn: Bool
    let isHost: Bool
    let isInvestmentCommand: Bool
    let timestamp: Date
    
    init(content: String, senderName: String, isOwn: Bool = false, isHost: Bool = false, isInvestmentCommand: Bool = false) {
        self.content = content
        self.senderName = senderName
        self.isOwn = isOwn
        self.isHost = isHost
        self.isInvestmentCommand = isInvestmentCommand
        self.timestamp = Date()
    }
}

struct PortfolioHolding: Identifiable {
    let id = UUID()
    let symbol: String
    let percentage: Double
    let returnRate: Double
}

struct ChatGroup {
    let id: String
    let name: String
    let host: String
    let memberCount: Int
}

// MARK: - View Models

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentGroup: ChatGroup?
    @Published var isHost: Bool = false
    @Published var investmentViewModel = InvestmentViewModel()
    
    private var messageListener: Task<Void, Never>?
    
    init() {
        // Set current user as host for demo
        isHost = true
        currentGroup = ChatGroup(
            id: "1",
            name: "科技股挑戰賽",
            host: "投資大師Tom",
            memberCount: 156
        )
    }
    
    func loadChatData() {
        // Load initial messages
        messages = [
            ChatMessage(content: "大家好！今天我們來討論一下科技股的趨勢", senderName: "投資大師Tom", isHost: true),
            ChatMessage(content: "AAPL 最近表現不錯，有什麼看法嗎？", senderName: "你", isOwn: true),
            ChatMessage(content: "[買入] AAPL 100K", senderName: "投資大師Tom", isHost: true, isInvestmentCommand: true),
            ChatMessage(content: "好決定！我也看好蘋果", senderName: "Lisa")
        ]
    }
    
    func sendMessage(_ content: String) {
        let newMessage = ChatMessage(content: content, senderName: "你", isOwn: true)
        
        withAnimation(.easeOut(duration: 0.3)) {
            messages.append(newMessage)
        }
        
        // Simulate sending to Supabase
        Task {
            await sendMessageToSupabase(newMessage)
        }
    }
    
    func startListeningForMessages() {
        // Simulate real-time message listening
        messageListener = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                
                await MainActor.run {
                    // Simulate receiving a message
                    if Bool.random() {
                        let randomMessages = [
                            "市場今天波動很大",
                            "大家要注意風險控制",
                            "科技股還有上漲空間嗎？"
                        ]
                        
                        let newMessage = ChatMessage(
                            content: randomMessages.randomElement() ?? "",
                            senderName: ["Kevin", "Lisa", "Mike"].randomElement() ?? "User"
                        )
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            messages.append(newMessage)
                        }
                    }
                }
            }
        }
    }
    
    func stopListeningForMessages() {
        messageListener?.cancel()
    }
    
    private func sendMessageToSupabase(_ message: ChatMessage) async {
        // Implementation for sending message to Supabase
        // This would use the Supabase client to insert the message
    }
}

class InvestmentViewModel: ObservableObject {
    @Published var portfolio: [PortfolioHolding] = []
    @Published var totalReturn: Double = 12.8
    @Published var availableFunds: Double = 650000
    
    init() {
        loadPortfolio()
    }
    
    func loadPortfolio() {
        portfolio = [
            PortfolioHolding(symbol: "AAPL", percentage: 30.0, returnRate: 8.5),
            PortfolioHolding(symbol: "TSLA", percentage: 20.0, returnRate: -2.3),
            PortfolioHolding(symbol: "NVDA", percentage: 25.0, returnRate: 15.2),
            PortfolioHolding(symbol: "GOOGL", percentage: 15.0, returnRate: 6.8)
        ]
    }
    
    func executeTradeCommand(action: String, symbol: String, amount: Double, commandText: String) {
        // Send command as chat message
        let commandMessage = ChatMessage(
            content: commandText,
            senderName: "你",
            isOwn: true,
            isInvestmentCommand: true
        )
        
        // This would be handled by the ChatViewModel
        NotificationCenter.default.post(
            name: NSNotification.Name("SendTradeCommand"),
            object: commandMessage
        )
        
        // Update portfolio with animation
        withAnimation(.easeInOut(duration: 0.3)) {
            updatePortfolio(action: action, symbol: symbol, amount: amount)
        }
        
        // Simulate API call to Alpha Vantage for real stock data
        Task {
            await fetchStockData(symbol: symbol)
        }
    }
    
    private func updatePortfolio(action: String, symbol: String, amount: Double) {
        // Simulate portfolio update
        if let index = portfolio.firstIndex(where: { $0.symbol == symbol }) {
            // Update existing holding
            let currentHolding = portfolio[index]
            let newPercentage = action == "Buy" ? 
                min(currentHolding.percentage + (amount / 10000), 50.0) :
                max(currentHolding.percentage - (amount / 10000), 0.0)
            
            portfolio[index] = PortfolioHolding(
                symbol: symbol,
                percentage: newPercentage,
                returnRate: currentHolding.returnRate + Double.random(in: -2...2)
            )
        } else if action == "Buy" {
            // Add new holding
            portfolio.append(PortfolioHolding(
                symbol: symbol,
                percentage: amount / 10000,
                returnRate: Double.random(in: -5...15)
            ))
        }
        
        // Update available funds
        availableFunds = action == "Buy" ? 
            max(availableFunds - amount, 0) :
            availableFunds + amount
        
        // Recalculate total return
        totalReturn = portfolio.reduce(0) { $0 + ($1.percentage * $1.returnRate / 100) }
    }
    
    private func fetchStockData(symbol: String) async {
        // Simulate Alpha Vantage API call
        // In real implementation, this would fetch actual stock data
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        await MainActor.run {
            // Update with "real" data
            if let index = portfolio.firstIndex(where: { $0.symbol == symbol }) {
                portfolio[index] = PortfolioHolding(
                    symbol: symbol,
                    percentage: portfolio[index].percentage,
                    returnRate: Double.random(in: -10...20) // Simulate real market data
                )
            }
        }
    }
}

// MARK: - Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ChatView()
}