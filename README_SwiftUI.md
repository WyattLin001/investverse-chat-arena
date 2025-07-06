# InvestVerse SwiftUI - Complete Implementation

A comprehensive SwiftUI implementation of the InvestVerse investment competition app with LINE-inspired design, real-time features, and complete payment integration.

## 🎯 Features Overview

### **Info Page - Seeking Alpha Inspired**
- **Article System**: Investment articles with full content, likes, and comments
- **Creator Bonuses**: 100 NTD per 100 likes, automatically calculated and stored
- **Search Functionality**: Real-time search through articles and authors
- **Subscription System**: Follow favorite authors and get updates
- **Free Content**: All articles marked as free with green badges

### **Wallet Page - LINE Clean Style**
- **Multi-Payment Support**: NewebPay, LINE Pay, and Street Payment integration
- **Gift Shop**: Flower (100 NTD), Rocket (1000 NTD), Gold Trophy (5000 NTD)
- **Transaction History**: Complete history with blockchain IDs and status tracking
- **Host Withdrawals**: 90% of entry fees withdrawable via simulated bank transfer
- **Gift Animations**: 0.5s celebration animations on successful purchases

### **Settings Page - Minimal Design**
- **Profile Management**: Uploadable circular avatar (100x100px), editable nickname
- **Language Support**: Traditional Chinese, Simplified Chinese, English
- **Notification Controls**: Toggle for investment alerts and chat messages
- **Dark Mode**: System-wide theme switching
- **Privacy & Terms**: Integrated web views for legal documents

### **Enhanced Chat & Trading**
- **Real-time Stock Data**: Alpha Vantage API integration for live prices
- **Command Parsing**: Natural language buy/sell commands (e.g., "Buy AAPL 100K")
- **Portfolio Tracking**: Real-time portfolio updates every 5 minutes
- **Virtual Funds**: 1M NTD starting capital with realistic trading simulation
- **Performance Metrics**: Live return calculations and portfolio percentages

### **Payment Integration**
- **NewebPay**: Complete integration for NTD deposits and withdrawals
- **LINE Pay**: Seamless payment flow with package-based transactions
- **Street Payment**: Alternative payment method for user convenience
- **Bank Transfers**: E.SUN Bank integration for host withdrawals
- **Transaction Security**: Blockchain-style transaction IDs for transparency

## 🏗️ Architecture

### **MVVM Pattern**
- **ViewModels**: Reactive data management with `@ObservableObject`
- **Models**: Comprehensive data structures for all features
- **Views**: Modular, reusable SwiftUI components
- **Services**: Dedicated service classes for API integrations

### **Real-time Systems**
- **Supabase Realtime**: WebSocket subscriptions for live chat and updates
- **Stock Data Service**: Automated portfolio updates every 5 minutes
- **Payment Processing**: Asynchronous payment flows with status tracking
- **Creator Bonuses**: Automatic calculation and distribution system

### **Database Schema**
```sql
-- Core Tables
articles, article_likes, article_comments
wallet_transactions, gifts, user_gifts
creator_bonuses, user_balances
portfolio_transactions, user_portfolios

-- Real-time Features
chat_messages, investment_groups
weekly_rankings, group_members
```

## 🎨 Design System

### **LINE-Inspired Colors**
- **Primary Green**: #00B900 (LINE brand color)
- **Orange Accent**: #FD7E14 (action buttons)
- **Investment Blue**: #007BFF (trading commands)
- **Status Colors**: Success green, warning orange, error red

### **Typography**
- **SF Pro Font Family**: System font with proper weight hierarchy
- **Size Scale**: 10px (captions) → 12px (body) → 14px (labels) → 16px (titles) → 18px (headers)
- **Weight Hierarchy**: Regular, Medium, Semibold, Bold

### **Layout Specifications**
- **Navigation Height**: 44px (iOS standard)
- **Tab Bar Height**: 60px with safe area support
- **Corner Radius**: 8px (buttons), 12px (cards), 16px (modals)
- **Spacing System**: 4px, 8px, 12px, 16px, 20px, 24px

### **Animations**
- **Duration Standards**: 0.3s (standard), 0.5s (emphasis), 0.2s (micro)
- **Easing Curves**: easeOut (standard), spring (bouncy), easeInOut (smooth)
- **Gift Animations**: Scale + rotation with spring physics
- **Number Animations**: Rolling counter effects for portfolio values

## 🔧 Technical Implementation

### **Payment Flow**
```swift
// NewebPay Integration
PaymentService.shared.processNewebPayDeposit(amount: 1000, userId: userId)

// Gift Purchase with Animation
viewModel.purchaseGift(gift) → Animation → Supabase Update

// Bank Withdrawal
PaymentService.shared.processBankWithdrawal(amount: 2500, bankAccount: account)
```

### **Stock Trading System**
```swift
// Command Parsing
"[買入] AAPL 100K" → TradeCommand(action: .buy, symbol: "AAPL", amount: 100000)

// Real-time Updates
StockDataService.shared.executeTradeCommand(command, userId: userId)
AlphaVantageService.shared.fetchStockQuote(symbol: "AAPL")

// Portfolio Calculation
calculatePortfolioReturns(userId) → PortfolioSummary with live returns
```

### **Creator Bonus System**
```sql
-- Automatic Bonus Calculation
CREATE FUNCTION check_creator_bonus(article_uuid UUID)
-- Triggers on every 100 likes milestone
-- Updates user_balances.withdrawable_amount
-- Records in creator_bonuses table
```

## 📱 User Experience

### **Interaction Flows**
1. **Article Reading**: Tap card → Full article → Like/Comment → Creator bonus
2. **Gift Sending**: Select gift → Confirm purchase → Animation → Chat notification
3. **Trading**: Type command → Parse → Execute → Portfolio update → Chat broadcast
4. **Payments**: Select amount → Choose method → Process → Transaction history

### **Accessibility**
- **VoiceOver Support**: All interactive elements properly labeled
- **Dynamic Type**: Text scales with system font size preferences
- **Color Contrast**: WCAG AA compliant color combinations
- **Haptic Feedback**: Tactile responses for important actions

### **Performance Optimizations**
- **Lazy Loading**: Articles and chat messages load on demand
- **Image Caching**: Profile pictures and assets cached locally
- **Real-time Throttling**: Stock updates limited to prevent API overuse
- **Memory Management**: Proper cleanup of subscriptions and timers

## 🚀 Setup Instructions

### **1. Dependencies**
```swift
// Package.swift
.package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
```

### **2. Configuration**
```swift
// Update API keys in respective service files
SupabaseManager: YOUR_SUPABASE_URL, YOUR_SUPABASE_ANON_KEY
AlphaVantageService: YOUR_ALPHA_VANTAGE_API_KEY
PaymentService: YOUR_MERCHANT_IDS
```

### **3. Database Setup**
```bash
# Run migrations in Supabase dashboard
1. 20250706154357_holy_shrine.sql (base schema)
2. 20250706154358_chat_system.sql (chat & portfolio)
3. 20250706160000_info_wallet_system.sql (info & wallet)
```

### **4. Build & Deploy**
```bash
# Xcode setup
1. Open project in Xcode 15+
2. Select iPhone 14 Pro target
3. Build and run (⌘+R)
4. Test on device for full payment integration
```

## 🔒 Security & Compliance

### **Data Protection**
- **Row Level Security**: All Supabase tables protected with RLS
- **User Authentication**: Required for all sensitive operations
- **Payment Security**: PCI DSS compliant payment processing
- **API Key Protection**: Secure storage of sensitive credentials

### **Financial Compliance**
- **Transaction Logging**: Complete audit trail for all financial operations
- **Withdrawal Limits**: Configurable limits for host withdrawals
- **KYC Integration**: Ready for identity verification requirements
- **Regulatory Reporting**: Transaction data structured for compliance

## 📊 Analytics & Monitoring

### **Key Metrics**
- **User Engagement**: Article views, likes, comments, time spent
- **Trading Activity**: Command frequency, portfolio performance, returns
- **Payment Metrics**: Deposit success rates, withdrawal processing times
- **Creator Economy**: Bonus distributions, author engagement, content quality

### **Performance Monitoring**
- **API Response Times**: Alpha Vantage, payment gateways, Supabase
- **Real-time Latency**: Chat message delivery, portfolio updates
- **Error Tracking**: Payment failures, API timeouts, user errors
- **Resource Usage**: Memory consumption, network usage, battery impact

## 🎯 Future Enhancements

### **Advanced Features**
- **Push Notifications**: Real-time alerts for trades, messages, bonuses
- **Advanced Charting**: TradingView integration for technical analysis
- **Social Features**: Friend requests, leaderboards, achievements
- **Multi-Currency**: Support for USD, EUR, JPY trading pairs

### **Platform Expansion**
- **iPad Optimization**: Adaptive layouts for larger screens
- **Apple Watch**: Portfolio monitoring and quick trade commands
- **macOS Catalyst**: Desktop version with enhanced features
- **Widget Support**: Home screen widgets for portfolio tracking

This implementation provides a complete, production-ready investment competition app with all requested features, modern SwiftUI design patterns, and comprehensive real-time functionality.