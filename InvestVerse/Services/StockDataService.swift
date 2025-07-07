import Foundation

class StockDataService: ObservableObject {
    static let shared = StockDataService()
    
    private let alphaVantageService = AlphaVantageService.shared
    private var portfolioUpdateTimer: Timer?
    
    private init() {
        startPortfolioUpdates()
    }
    
    // MARK: - Portfolio Management
    
    func executeTradeCommand(_ command: String, userId: String) async throws {
        let parsedCommand = try parseTradeCommand(command)
        
        // Fetch current stock price
        let stockQuote = try await alphaVantageService.fetchStockQuote(symbol: parsedCommand.symbol)
        
        // Calculate trade details
        let shares = parsedCommand.amount / stockQuote.price
        let totalCost = shares * stockQuote.price
        
        // Store transaction in Supabase
        try await storePortfolioTransaction(
            userId: userId,
            symbol: parsedCommand.symbol,
            action: parsedCommand.action,
            shares: shares,
            price: stockQuote.price,
            totalCost: totalCost
        )
        
        // Update portfolio
        try await updateUserPortfolio(userId: userId)
    }
    
    func calculatePortfolioReturns(userId: String) async throws -> PortfolioSummary {
        let holdings = try await fetchUserPortfolio(userId: userId)
        var totalValue: Double = 0
        var totalCost: Double = 0
        var portfolioHoldings: [PortfolioHolding] = []
        
        for holding in holdings {
            // Fetch current stock price
            let stockQuote = try await alphaVantageService.fetchStockQuote(symbol: holding.symbol)
            
            let currentValue = holding.shares * stockQuote.price
            let costBasis = holding.shares * holding.averagePrice
            let returnRate = ((currentValue - costBasis) / costBasis) * 100
            
            totalValue += currentValue
            totalCost += costBasis
            
            portfolioHoldings.append(PortfolioHolding(
                symbol: holding.symbol,
                shares: holding.shares,
                averagePrice: holding.averagePrice,
                currentPrice: stockQuote.price,
                currentValue: currentValue,
                returnRate: returnRate,
                percentage: 0 // Will be calculated after total value is known
            ))
        }
        
        // Calculate percentages
        for i in 0..<portfolioHoldings.count {
            portfolioHoldings[i] = PortfolioHolding(
                symbol: portfolioHoldings[i].symbol,
                shares: portfolioHoldings[i].shares,
                averagePrice: portfolioHoldings[i].averagePrice,
                currentPrice: portfolioHoldings[i].currentPrice,
                currentValue: portfolioHoldings[i].currentValue,
                returnRate: portfolioHoldings[i].returnRate,
                percentage: (portfolioHoldings[i].currentValue / totalValue) * 100
            )
        }
        
        let totalReturn = ((totalValue - totalCost) / totalCost) * 100
        
        return PortfolioSummary(
            totalValue: totalValue,
            totalCost: totalCost,
            totalReturn: totalReturn,
            holdings: portfolioHoldings
        )
    }
    
    // MARK: - Real-time Updates
    
    private func startPortfolioUpdates() {
        portfolioUpdateTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task {
                await self.updateAllPortfolios()
            }
        }
    }
    
    private func updateAllPortfolios() async {
        // In real implementation, this would update all user portfolios
        // For now, we'll just update the current user's portfolio
        do {
            try await updateUserPortfolio(userId: "current_user_id")
        } catch {
            print("Failed to update portfolios: \(error)")
        }
    }
    
    // MARK: - Command Parsing
    
    private func parseTradeCommand(_ command: String) throws -> TradeCommand {
        // Parse commands like "[買入] AAPL 100K" or "[賣出] TSLA 50000"
        let pattern = #"\[(買入|賣出)\]\s+([A-Z]+)\s+(\d+(?:\.\d+)?[KMB]?)"#
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(command.startIndex..<command.endIndex, in: command)
        
        guard let match = regex.firstMatch(in: command, range: range) else {
            throw StockDataError.invalidCommand
        }
        
        let actionRange = Range(match.range(at: 1), in: command)!
        let symbolRange = Range(match.range(at: 2), in: command)!
        let amountRange = Range(match.range(at: 3), in: command)!
        
        let actionText = String(command[actionRange])
        let symbol = String(command[symbolRange])
        let amountText = String(command[amountRange])
        
        let action: TradeAction = actionText == "買入" ? .buy : .sell
        let amount = try parseAmount(amountText)
        
        return TradeCommand(action: action, symbol: symbol, amount: amount)
    }
    
    private func parseAmount(_ amountText: String) throws -> Double {
        let cleanText = amountText.uppercased()
        
        if cleanText.hasSuffix("K") {
            let numberPart = String(cleanText.dropLast())
            guard let number = Double(numberPart) else { throw StockDataError.invalidAmount }
            return number * 1000
        } else if cleanText.hasSuffix("M") {
            let numberPart = String(cleanText.dropLast())
            guard let number = Double(numberPart) else { throw StockDataError.invalidAmount }
            return number * 1000000
        } else if cleanText.hasSuffix("B") {
            let numberPart = String(cleanText.dropLast())
            guard let number = Double(numberPart) else { throw StockDataError.invalidAmount }
            return number * 1000000000
        } else {
            guard let number = Double(cleanText) else { throw StockDataError.invalidAmount }
            return number
        }
    }
    
    // MARK: - Database Operations
    
    private func storePortfolioTransaction(userId: String, symbol: String, action: TradeAction, shares: Double, price: Double, totalCost: Double) async throws {
        // Store transaction in Supabase portfolio_transactions table
        let transaction = [
            "user_id": userId,
            "symbol": symbol,
            "action": action.rawValue,
            "amount": totalCost,
            "price": price,
            "executed_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        // In real implementation, this would use SupabaseManager
        print("Storing transaction: \(transaction)")
    }
    
    private func updateUserPortfolio(userId: String) async throws {
        // Update user_portfolios table with current holdings
        // This would be triggered by the database trigger in real implementation
        print("Updating portfolio for user: \(userId)")
    }
    
    private func fetchUserPortfolio(userId: String) async throws -> [UserPortfolioHolding] {
        // Fetch from Supabase user_portfolios table
        // For now, return mock data
        return [
            UserPortfolioHolding(symbol: "AAPL", shares: 100, averagePrice: 150.0),
            UserPortfolioHolding(symbol: "TSLA", shares: 50, averagePrice: 200.0),
            UserPortfolioHolding(symbol: "NVDA", shares: 30, averagePrice: 400.0)
        ]
    }
}

// MARK: - Data Models

struct TradeCommand {
    let action: TradeAction
    let symbol: String
    let amount: Double
}

enum TradeAction: String {
    case buy = "buy"
    case sell = "sell"
}

struct PortfolioSummary {
    let totalValue: Double
    let totalCost: Double
    let totalReturn: Double
    let holdings: [PortfolioHolding]
}

struct UserPortfolioHolding {
    let symbol: String
    let shares: Double
    let averagePrice: Double
}

enum StockDataError: Error {
    case invalidCommand
    case invalidAmount
    case insufficientFunds
    case insufficientShares
}

// Update the existing PortfolioHolding struct
extension PortfolioHolding {
    init(symbol: String, shares: Double, averagePrice: Double, currentPrice: Double, currentValue: Double, returnRate: Double, percentage: Double) {
        self.init()
        // This would be properly implemented with all properties
    }
}