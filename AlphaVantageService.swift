import Foundation

class AlphaVantageService: ObservableObject {
    static let shared = AlphaVantageService()
    
    private let apiKey = "YOUR_ALPHA_VANTAGE_API_KEY"
    private let baseURL = "https://www.alphavantage.co/query"
    
    private init() {}
    
    // MARK: - Stock Data Operations
    
    func fetchStockQuote(symbol: String) async throws -> StockQuote {
        let urlString = "\(baseURL)?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(StockQuoteResponse.self, from: data)
        
        guard let quote = response.globalQuote else {
            throw APIError.noData
        }
        
        return StockQuote(
            symbol: quote.symbol,
            price: Double(quote.price) ?? 0.0,
            change: Double(quote.change) ?? 0.0,
            changePercent: parseChangePercent(quote.changePercent)
        )
    }
    
    func fetchIntradayData(symbol: String) async throws -> [StockDataPoint] {
        let urlString = "\(baseURL)?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=5min&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(IntradayResponse.self, from: data)
        
        guard let timeSeries = response.timeSeries else {
            throw APIError.noData
        }
        
        return timeSeries.compactMap { (timestamp, data) in
            guard let price = Double(data.close) else { return nil }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard let date = formatter.date(from: timestamp) else { return nil }
            
            return StockDataPoint(timestamp: date, price: price)
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func parseChangePercent(_ changePercent: String) -> Double {
        let cleanString = changePercent.replacingOccurrences(of: "%", with: "")
        return Double(cleanString) ?? 0.0
    }
}

// MARK: - Data Models

struct StockQuote {
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: Double
}

struct StockDataPoint {
    let timestamp: Date
    let price: Double
}

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
}

// MARK: - Response Models

struct StockQuoteResponse: Codable {
    let globalQuote: GlobalQuote?
    
    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
    }
}

struct GlobalQuote: Codable {
    let symbol: String
    let price: String
    let change: String
    let changePercent: String
    
    enum CodingKeys: String, CodingKey {
        case symbol = "01. symbol"
        case price = "05. price"
        case change = "09. change"
        case changePercent = "10. change percent"
    }
}

struct IntradayResponse: Codable {
    let timeSeries: [String: IntradayData]?
    
    enum CodingKeys: String, CodingKey {
        case timeSeries = "Time Series (5min)"
    }
}

struct IntradayData: Codable {
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}