# InvestVerse SwiftUI App

A SwiftUI implementation of the InvestVerse investment competition app with LINE-inspired design.

## Features

- **Home Page**: Displays NTD balance, weekly rankings, and investment groups
- **LINE-inspired Design**: Card-based layout with clean, modern aesthetics
- **Animated Rankings**: 0.5s number scroll animation for return percentages
- **Supabase Integration**: Real-time data storage and retrieval
- **Tab Navigation**: 5-tab bottom navigation with SF Symbols

## Setup

1. **Install Dependencies**:
   ```bash
   # Add Supabase Swift package to your Xcode project
   # File > Add Package Dependencies
   # https://github.com/supabase/supabase-swift.git
   ```

2. **Configure Supabase**:
   - Update `SupabaseManager.swift` with your Supabase URL and anon key
   - Run the SQL schema in your Supabase dashboard

3. **Build and Run**:
   - Open the project in Xcode
   - Select iPhone 14 Pro simulator
   - Build and run the app

## Architecture

- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive data binding
- **Supabase**: Backend as a service for data storage
- **SwiftUI**: Declarative UI framework

## Key Components

- `HomeView`: Main home page with rankings and groups
- `TopNavigationBar`: 44px navigation bar with balance and actions
- `WeeklyRankingView`: Animated rankings display
- `GroupCardView`: Investment group cards with join functionality
- `SupabaseManager`: Database operations and API calls

## Database Schema

The app uses three main tables:
- `investment_groups`: Store group information
- `weekly_rankings`: Track weekly performance
- `group_members`: Manage group memberships

## Design Specifications

- **Colors**: LINE green (#00B900), gold (#FFD700), silver (#C0C0C0), bronze (#CD7F32)
- **Typography**: SF Pro with various weights and sizes
- **Layout**: Responsive design optimized for iPhone 14 Pro
- **Animations**: Smooth 0.5s easing animations for number updates

## Navigation

Tapping "Join Group" navigates to the Wallet tab, maintaining the app's flow and user experience.