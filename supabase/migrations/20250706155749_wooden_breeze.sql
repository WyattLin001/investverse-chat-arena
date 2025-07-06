/*
  # Chat System Schema

  1. New Tables
    - `chat_messages`
      - `id` (uuid, primary key)
      - `group_id` (uuid, foreign key to investment_groups)
      - `sender_id` (uuid, user identifier)
      - `sender_name` (text)
      - `content` (text)
      - `is_investment_command` (boolean)
      - `created_at` (timestamp)
    
    - `portfolio_transactions`
      - `id` (uuid, primary key)
      - `user_id` (uuid)
      - `symbol` (text)
      - `action` (text) - 'buy' or 'sell'
      - `amount` (decimal)
      - `price` (decimal)
      - `executed_at` (timestamp)
    
    - `user_portfolios`
      - `id` (uuid, primary key)
      - `user_id` (uuid)
      - `symbol` (text)
      - `shares` (decimal)
      - `average_price` (decimal)
      - `current_value` (decimal)
      - `return_rate` (decimal)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to read/write their own data
    - Add policies for group members to read group chat messages
*/

-- Chat Messages Table
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid REFERENCES investment_groups(id) ON DELETE CASCADE,
  sender_id uuid DEFAULT auth.uid(),
  sender_name text NOT NULL,
  content text NOT NULL,
  is_investment_command boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Portfolio Transactions Table
CREATE TABLE IF NOT EXISTS portfolio_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid(),
  symbol text NOT NULL,
  action text NOT NULL CHECK (action IN ('buy', 'sell')),
  amount decimal(15,2) NOT NULL,
  price decimal(10,2),
  executed_at timestamptz DEFAULT now()
);

-- User Portfolios Table
CREATE TABLE IF NOT EXISTS user_portfolios (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid(),
  symbol text NOT NULL,
  shares decimal(15,4) NOT NULL DEFAULT 0,
  average_price decimal(10,2) NOT NULL DEFAULT 0,
  current_value decimal(15,2) NOT NULL DEFAULT 0,
  return_rate decimal(5,2) NOT NULL DEFAULT 0,
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, symbol)
);

-- Enable Row Level Security
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_portfolios ENABLE ROW LEVEL SECURITY;

-- RLS Policies for chat_messages
CREATE POLICY "Group members can view chat messages"
  ON chat_messages
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = chat_messages.group_id 
      AND group_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Group members can send chat messages"
  ON chat_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = chat_messages.group_id 
      AND group_members.user_id = auth.uid()
    )
  );

-- RLS Policies for portfolio_transactions
CREATE POLICY "Users can view own transactions"
  ON portfolio_transactions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own transactions"
  ON portfolio_transactions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policies for user_portfolios
CREATE POLICY "Users can view own portfolio"
  ON user_portfolios
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own portfolio"
  ON user_portfolios
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_chat_messages_group_id ON chat_messages(group_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_portfolio_transactions_user_id ON portfolio_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_portfolios_user_id ON user_portfolios(user_id);

-- Insert sample chat messages
INSERT INTO chat_messages (group_id, sender_name, content, is_investment_command) 
SELECT 
  ig.id,
  '投資大師Tom',
  '大家好！今天我們來討論一下科技股的趨勢',
  false
FROM investment_groups ig 
WHERE ig.name = '科技股挑戰賽'
LIMIT 1;

INSERT INTO chat_messages (group_id, sender_name, content, is_investment_command) 
SELECT 
  ig.id,
  '投資大師Tom',
  '[買入] AAPL 100K',
  true
FROM investment_groups ig 
WHERE ig.name = '科技股挑戰賽'
LIMIT 1;

-- Insert sample portfolio data
INSERT INTO user_portfolios (user_id, symbol, shares, average_price, current_value, return_rate) VALUES
('00000000-0000-0000-0000-000000000001', 'AAPL', 100, 150.00, 15500.00, 8.5),
('00000000-0000-0000-0000-000000000001', 'TSLA', 50, 200.00, 9800.00, -2.3),
('00000000-0000-0000-0000-000000000001', 'NVDA', 30, 400.00, 13800.00, 15.2),
('00000000-0000-0000-0000-000000000001', 'GOOGL', 25, 120.00, 3200.00, 6.8);

-- Function to update portfolio after transaction
CREATE OR REPLACE FUNCTION update_portfolio_after_transaction()
RETURNS TRIGGER AS $$
BEGIN
  -- Update or insert portfolio holding
  INSERT INTO user_portfolios (user_id, symbol, shares, average_price, current_value, return_rate)
  VALUES (
    NEW.user_id,
    NEW.symbol,
    CASE WHEN NEW.action = 'buy' THEN NEW.amount / COALESCE(NEW.price, 100) ELSE -(NEW.amount / COALESCE(NEW.price, 100)) END,
    COALESCE(NEW.price, 100),
    NEW.amount,
    0
  )
  ON CONFLICT (user_id, symbol)
  DO UPDATE SET
    shares = user_portfolios.shares + CASE WHEN NEW.action = 'buy' THEN NEW.amount / COALESCE(NEW.price, 100) ELSE -(NEW.amount / COALESCE(NEW.price, 100)) END,
    current_value = user_portfolios.current_value + CASE WHEN NEW.action = 'buy' THEN NEW.amount ELSE -NEW.amount END,
    updated_at = now();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for portfolio updates
CREATE TRIGGER trigger_update_portfolio
  AFTER INSERT ON portfolio_transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_portfolio_after_transaction();