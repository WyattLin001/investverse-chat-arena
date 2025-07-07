import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel = WalletViewModel()
    @State private var selectedTab = 3
    @State private var showGiftAnimation = false
    @State private var selectedGift: Gift?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Navigation Bar
                WalletNavigationBar(balance: viewModel.balance)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Deposit Section
                        DepositSectionView(balance: viewModel.balance) {
                            viewModel.showDepositOptions = true
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Gift Shop
                        GiftShopView(gifts: viewModel.gifts) { gift in
                            selectedGift = gift
                            viewModel.purchaseGift(gift)
                            showGiftAnimation = true
                        }
                        .padding(.horizontal, 16)
                        
                        // Host Withdrawal (if user is host)
                        if viewModel.isHost {
                            WithdrawalSectionView(
                                withdrawableAmount: viewModel.withdrawableAmount
                            ) {
                                viewModel.requestWithdrawal()
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Transaction History
                        TransactionHistoryView(transactions: viewModel.transactions)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
                .background(Color(hex: "F5F5F5"))
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showDepositOptions) {
            DepositOptionsView(viewModel: viewModel)
        }
        .overlay(
            GiftAnimationView(
                gift: selectedGift,
                isVisible: $showGiftAnimation
            )
        )
        .onAppear {
            viewModel.loadWalletData()
        }
    }
}

struct WalletNavigationBar: View {
    let balance: Int
    
    var body: some View {
        HStack {
            Text("錢包")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("NTD 餘額")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text("NTD \(balance.formatted())")
                    .font(.system(size: 16, weight: .bold))
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

struct DepositSectionView: View {
    let balance: Int
    let onDepositTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("儲值")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Button(action: onDepositTapped) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        Text("LINE Pay 儲值")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(hex: "00B900"))
                    .cornerRadius(8)
                }
                
                Button(action: onDepositTapped) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "FD7E14"))
                        
                        Text("街口支付")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "FD7E14"))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "FD7E14"), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct GiftShopView: View {
    let gifts: [Gift]
    let onPurchase: (Gift) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("禮物商店")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(gifts) { gift in
                    GiftCardView(gift: gift) {
                        onPurchase(gift)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct GiftCardView: View {
    let gift: Gift
    let onPurchase: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Gift Icon
            Text(gift.icon)
                .font(.system(size: 32))
                .frame(width: 48, height: 48)
                .background(gift.backgroundColor)
                .cornerRadius(8)
            
            // Gift Info
            VStack(alignment: .leading, spacing: 4) {
                Text(gift.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(gift.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Price and Buy Button
            VStack(alignment: .trailing, spacing: 8) {
                Text("NT$ \(gift.price)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Button(action: onPurchase) {
                    Text("購買")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(hex: "00B900"))
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct WithdrawalSectionView: View {
    let withdrawableAmount: Int
    let onWithdrawTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("主持人提領")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("可提領金額")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("NT$ \(withdrawableAmount.formatted())")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "00B900"))
                    
                    Text("(已扣除 5% 平台手續費)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onWithdrawTapped) {
                    Text("申請提領")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "FD7E14"))
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct TransactionHistoryView: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("交易記錄")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                    
                    if transaction.id != transactions.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.type)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TransactionStatusBadge(status: transaction.status)
                }
                
                Text(transaction.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(transaction.time)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    if !transaction.blockchainId.isEmpty {
                        Button("區塊鏈記錄") {
                            // Open blockchain explorer
                        }
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "007BFF"))
                    }
                }
            }
            
            Spacer()
            
            Text("\(transaction.amount >= 0 ? "+" : "")NT$ \(abs(transaction.amount).formatted())")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(transaction.amount >= 0 ? Color(hex: "00B900") : .red)
        }
    }
}

struct TransactionStatusBadge: View {
    let status: TransactionStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(status == .confirmed ? Color(hex: "00B900") : Color(hex: "FD7E14"))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(status == .confirmed ? Color(hex: "00B900").opacity(0.1) : Color(hex: "FD7E14").opacity(0.1))
            .cornerRadius(4)
    }
}

struct DepositOptionsView: View {
    @ObservedObject var viewModel: WalletViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedAmount = 1000
    
    private let amounts = [500, 1000, 2000, 5000, 10000]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Amount Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("選擇儲值金額")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(amounts, id: \.self) { amount in
                            Button(action: {
                                selectedAmount = amount
                            }) {
                                Text("NT$ \(amount)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedAmount == amount ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(selectedAmount == amount ? Color(hex: "00B900") : Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Payment Methods
                VStack(alignment: .leading, spacing: 16) {
                    Text("選擇付款方式")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        PaymentMethodButton(
                            title: "LINE Pay",
                            icon: "creditcard.fill",
                            color: Color(hex: "00B900")
                        ) {
                            viewModel.processPayment(amount: selectedAmount, method: .linePay)
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        PaymentMethodButton(
                            title: "街口支付",
                            icon: "wallet.pass.fill",
                            color: Color(hex: "FD7E14")
                        ) {
                            viewModel.processPayment(amount: selectedAmount, method: .streetPayment)
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        PaymentMethodButton(
                            title: "NewebPay",
                            icon: "creditcard.circle.fill",
                            color: Color(hex: "007BFF")
                        ) {
                            viewModel.processPayment(amount: selectedAmount, method: .newebPay)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .navigationTitle("儲值")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct PaymentMethodButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct GiftAnimationView: View {
    let gift: Gift?
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible, let gift = gift {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text(gift.icon)
                        .font(.system(size: 80))
                        .scaleEffect(isVisible ? 1.0 : 0.1)
                        .rotationEffect(.degrees(isVisible ? 360 : 0))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isVisible)
                    
                    Text("購買成功！")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.3), value: isVisible)
                    
                    Text("已獲得 \(gift.name)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(isVisible ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.5), value: isVisible)
                }
                .padding(32)
                .background(Color.black.opacity(0.7))
                .cornerRadius(16)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                    }
                }
            }
        }
    }
}

// MARK: - Data Models

struct Gift: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    let icon: String
    let description: String
    let backgroundColor: Color
}

struct Transaction: Identifiable {
    let id = UUID()
    let type: String
    let amount: Int
    let description: String
    let status: TransactionStatus
    let time: String
    let blockchainId: String
}

enum TransactionStatus: String, CaseIterable {
    case confirmed = "已確認"
    case pending = "處理中"
}

enum PaymentMethod {
    case linePay
    case streetPayment
    case newebPay
}

// MARK: - View Model

class WalletViewModel: ObservableObject {
    @Published var balance: Int = 5000
    @Published var withdrawableAmount: Int = 2500
    @Published var isHost: Bool = true
    @Published var gifts: [Gift] = []
    @Published var transactions: [Transaction] = []
    @Published var showDepositOptions = false
    
    func loadWalletData() {
        gifts = [
            Gift(
                name: "花束",
                price: 100,
                icon: "🌸",
                description: "表達支持的小禮物",
                backgroundColor: Color.pink.opacity(0.2)
            ),
            Gift(
                name: "火箭",
                price: 1000,
                icon: "🚀",
                description: "推動投資組合起飛",
                backgroundColor: Color.red.opacity(0.2)
            ),
            Gift(
                name: "黃金",
                price: 5000,
                icon: "🏆",
                description: "最高等級的認可",
                backgroundColor: Color.yellow.opacity(0.2)
            )
        ]
        
        transactions = [
            Transaction(
                type: "購買禮物",
                amount: -200,
                description: "花束 x2 → 科技股挑戰賽",
                status: .confirmed,
                time: "2024-01-15 14:30",
                blockchainId: "0x1234...abcd"
            ),
            Transaction(
                type: "儲值",
                amount: 1000,
                description: "LINE Pay 儲值",
                status: .confirmed,
                time: "2024-01-15 10:15",
                blockchainId: "0x5678...efgh"
            ),
            Transaction(
                type: "購買禮物",
                amount: -1000,
                description: "火箭 x1 → 綠能投資群",
                status: .pending,
                time: "2024-01-14 16:45",
                blockchainId: "0x9abc...ijkl"
            )
        ]
    }
    
    func purchaseGift(_ gift: Gift) {
        guard balance >= gift.price else {
            // Show insufficient balance alert
            return
        }
        
        // Update balance
        balance -= gift.price
        
        // Add transaction record
        let newTransaction = Transaction(
            type: "購買禮物",
            amount: -gift.price,
            description: "\(gift.name) x1",
            status: .confirmed,
            time: DateFormatter.transactionFormatter.string(from: Date()),
            blockchainId: generateBlockchainId()
        )
        
        transactions.insert(newTransaction, at: 0)
        
        // Store in Supabase
        Task {
            await storeTransactionInSupabase(newTransaction)
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func processPayment(amount: Int, method: PaymentMethod) {
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.balance += amount
            
            let methodName = {
                switch method {
                case .linePay: return "LINE Pay"
                case .streetPayment: return "街口支付"
                case .newebPay: return "NewebPay"
                }
            }()
            
            let newTransaction = Transaction(
                type: "儲值",
                amount: amount,
                description: "\(methodName) 儲值",
                status: .confirmed,
                time: DateFormatter.transactionFormatter.string(from: Date()),
                blockchainId: self.generateBlockchainId()
            )
            
            self.transactions.insert(newTransaction, at: 0)
            
            // Store in Supabase
            Task {
                await self.storeTransactionInSupabase(newTransaction)
            }
        }
    }
    
    func requestWithdrawal() {
        // Simulate withdrawal request
        let newTransaction = Transaction(
            type: "提領申請",
            amount: -withdrawableAmount,
            description: "提領至 E.SUN Bank",
            status: .pending,
            time: DateFormatter.transactionFormatter.string(from: Date()),
            blockchainId: generateBlockchainId()
        )
        
        transactions.insert(newTransaction, at: 0)
        withdrawableAmount = 0
        
        // Store in Supabase
        Task {
            await storeTransactionInSupabase(newTransaction)
        }
    }
    
    private func generateBlockchainId() -> String {
        return "0x" + String((0..<8).map { _ in "0123456789abcdef".randomElement()! })
    }
    
    private func storeTransactionInSupabase(_ transaction: Transaction) async {
        // Implementation for storing transaction in Supabase
    }
}

extension DateFormatter {
    static let transactionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
}

#Preview {
    WalletView()
}