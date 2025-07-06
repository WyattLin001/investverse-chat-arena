# InvestVerse SwiftUI App

A SwiftUI implementation of the InvestVerse investment competition app with LINE-inspired design and real-time chat functionality.

## Features

### Home Page
- **LINE-inspired Design**: Card-based layout with clean, modern aesthetics
- **NTD Balance Display**: Shows current balance in top navigation
- **Weekly Rankings**: Animated top 3 hosts with gold, silver, bronze badges
- **Investment Groups**: Scrollable list of groups with join functionality
- **Tab Navigation**: 5-tab bottom navigation with SF Symbols

### Chat Page
- **Real-time Chat**: LINE-style chat bubbles with sent/received messages
- **Investment Commands**: Highlighted buy/sell commands in blue
- **Host Investment Panel**: Collapsible trading interface for hosts
- **Portfolio Display**: Real-time portfolio overview with returns
- **Gift Integration**: Send gifts button navigates to wallet

## Technical Stack

- **SwiftUI**: Declarative UI framework
- **Supabase**: Backend as a service with real-time subscriptions
- **Alpha Vantage API**: Real-time stock market data
- **Socket.io**: Real-time communication (alternative to Supabase realtime)
- **MVVM Architecture**: Clean separation of concerns

## Setup

1. **Install Dependencies**:
   ```bash
   # Add packages to your Xcode project
   # File > Add Package Dependencies
   
   # Supabase Swift
   https://github.com/supabase/supabase-swift.git
   
   # Socket.IO (optional, for alternative real-time implementation)
   https://github.com/socketio/socket.io-client-swift.git
   ```

2. **Configure Supabase**:
   - Update `SupabaseManager.swift` and `SupabaseRealtimeManager.swift` with your Supabase URL and anon key
   - Run the SQL migrations in your Supabase dashboard:
     - `20250706154357_holy_shrine.sql` (base schema)
     - `20250706154358_chat_system.sql` (chat and portfolio system)

3. **Configure Alpha Vantage**:
   - Get a free API key from [Alpha Vantage](https://www.alphavantage.co/support/#api-key)
   - Update `AlphaVantageService.swift` with your API key

4. **Build and Run**:
   - Open the project in Xcode
   - Select iPhone 14 Pro simulator
   - Build and run the app

## Architecture

### Core Components

- **ContentView**: Main tab container with navigation
- **HomeView**: Investment groups and rankings display
- **ChatView**: Real-time chat with investment commands
- **InvestmentPanelView**: Host-only trading interface
- **SupabaseManager**: Database operations
- **SupabaseRealtimeManager**: Real-time subscriptions
- **AlphaVantageService**: Stock market data integration

### Data Models

- **ChatMessage**: Chat message with investment command support
- **InvestmentGroup**: Group information and metadata
- **PortfolioHolding**: Individual stock holdings
- **StockQuote**: Real-time stock price data

### Database Schema

The app uses several Supabase tables:
- `investment_groups`: Store group information
- `weekly_rankings`: Track weekly performance
- `group_members`: Manage group memberships
- `chat_messages`: Real-time chat messages
- `portfolio_transactions`: Trading history
- `user_portfolios`: Current portfolio holdings

## Key Features

### Real-time Chat
- LINE-inspired bubble design with green sent messages
- Host messages highlighted with badges
- Investment commands displayed in blue bubbles
- Real-time message delivery via Supabase subscriptions

### Investment Trading
- Host-only collapsible trading panel
- Buy/sell commands with stock symbol and amount
- Real-time portfolio updates with 0.3s animations
- Integration with Alpha Vantage for live stock prices

### Navigation Flow
- Tap "Join Group" → Navigate to Wallet tab
- Tap "Send Gift" → Navigate to Wallet tab
- Smooth tab transitions with highlighted states

## Design Specifications

### Colors
- **LINE Green**: #00B900 (primary brand color)
- **Investment Blue**: #007BFF (trading commands)
- **Orange**: #FD7E14 (join group buttons)
- **Gold/Silver/Bronze**: #FFD700, #C0C0C0, #CD7F32 (rankings)

### Typography
- **SF Pro**: System font with various weights
- **Sizes**: 16px (titles), 14px (body), 12px (captions)

### Layout
- **44px**: Navigation bar height
- **40px**: Input area height
- **60px**: Tab bar height
- **12px**: Standard corner radius
- **16px**: Standard padding

### Animations
- **0.3s**: Standard transition duration
- **0.5s**: Number roll animations
- **easeOut**: Standard easing curve

## API Integration

### Supabase Real-time
```swift
// Subscribe to chat messages
supabaseManager.subscribeToChat(groupId: "group-id") { message in
    // Handle new message
}

// Send investment command
await supabaseManager.sendMessage(
    groupId: "group-id",
    content: "[買入] AAPL 100K",
    senderName: "Host",
    isInvestmentCommand: true
)
```

### Alpha Vantage Stock Data
```swift
// Fetch real-time stock quote
let quote = try await alphaVantageService.fetchStockQuote(symbol: "AAPL")

// Get intraday price data
let dataPoints = try await alphaVantageService.fetchIntradayData(symbol: "AAPL")
```

## Security

- **Row Level Security (RLS)**: Enabled on all Supabase tables
- **User Authentication**: Required for chat and trading
- **Group Membership**: Verified before chat access
- **API Key Protection**: Alpha Vantage key stored securely

## Performance Optimizations

- **Lazy Loading**: Chat messages and portfolio data
- **Real-time Subscriptions**: Efficient WebSocket connections
- **Animation Optimization**: 60fps smooth transitions
- **Memory Management**: Proper cleanup of subscriptions

## Testing

The app includes comprehensive test coverage for:
- Chat message handling
- Portfolio calculations
- Real-time subscriptions
- API integrations
- UI animations

## Deployment

The app is ready for TestFlight and App Store deployment with:
- Production Supabase configuration
- Alpha Vantage API rate limiting
- Proper error handling
- User analytics integration

## Future Enhancements

- Push notifications for chat messages
- Advanced charting with stock price history
- Social features (friend requests, leaderboards)
- Multiple currency support
- Dark mode theme