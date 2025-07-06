/*
  # Info and Wallet System Migration

  1. New Tables
    - `articles` - Store investment articles and content
    - `article_likes` - Track user likes on articles
    - `article_comments` - Store user comments on articles
    - `wallet_transactions` - Store all wallet transactions
    - `gifts` - Store available gifts in the shop
    - `user_gifts` - Track gifts purchased by users
    - `creator_bonuses` - Track creator bonus payments

  2. Security
    - Enable RLS on all new tables
    - Add appropriate policies for each table
    - Ensure users can only access their own data

  3. Features
    - Article system with likes and comments
    - Creator bonus calculation (100 NTD per 100 likes)
    - Wallet system with deposits and withdrawals
    - Gift shop with purchase tracking
    - Transaction history with blockchain IDs
*/

-- Articles Table
CREATE TABLE IF NOT EXISTS articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    author_id UUID,
    summary TEXT NOT NULL,
    full_content TEXT NOT NULL,
    category TEXT NOT NULL,
    read_time TEXT NOT NULL DEFAULT '5 分鐘',
    likes_count INTEGER NOT NULL DEFAULT 0,
    comments_count INTEGER NOT NULL DEFAULT 0,
    is_free BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Article Likes Table
CREATE TABLE IF NOT EXISTS article_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id UUID REFERENCES articles(id) ON DELETE CASCADE,
    user_id UUID NOT NULL DEFAULT auth.uid(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(article_id, user_id)
);

-- Article Comments Table
CREATE TABLE IF NOT EXISTS article_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id UUID REFERENCES articles(id) ON DELETE CASCADE,
    user_id UUID NOT NULL DEFAULT auth.uid(),
    user_name TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Wallet Transactions Table
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid(),
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('deposit', 'withdrawal', 'gift_purchase', 'entry_fee', 'bonus')),
    amount INTEGER NOT NULL,
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'pending', 'failed')),
    payment_method TEXT,
    blockchain_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Gifts Table
CREATE TABLE IF NOT EXISTS gifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    price INTEGER NOT NULL,
    icon TEXT NOT NULL,
    description TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Gifts Table
CREATE TABLE IF NOT EXISTS user_gifts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid(),
    gift_id UUID REFERENCES gifts(id) ON DELETE CASCADE,
    recipient_group_id UUID REFERENCES investment_groups(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    total_cost INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Creator Bonuses Table
CREATE TABLE IF NOT EXISTS creator_bonuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    article_id UUID REFERENCES articles(id) ON DELETE CASCADE,
    author_id UUID NOT NULL,
    likes_milestone INTEGER NOT NULL,
    bonus_amount INTEGER NOT NULL,
    paid_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(article_id, likes_milestone)
);

-- User Balances Table
CREATE TABLE IF NOT EXISTS user_balances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() UNIQUE,
    balance INTEGER NOT NULL DEFAULT 0,
    withdrawable_amount INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE gifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_gifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE creator_bonuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_balances ENABLE ROW LEVEL SECURITY;

-- RLS Policies for articles
CREATE POLICY "Anyone can view articles"
    ON articles
    FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE POLICY "Authors can create articles"
    ON articles
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors can update own articles"
    ON articles
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = author_id)
    WITH CHECK (auth.uid() = author_id);

-- RLS Policies for article_likes
CREATE POLICY "Users can view all likes"
    ON article_likes
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can like articles"
    ON article_likes
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike articles"
    ON article_likes
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- RLS Policies for article_comments
CREATE POLICY "Anyone can view comments"
    ON article_comments
    FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE POLICY "Users can create comments"
    ON article_comments
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments"
    ON article_comments
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- RLS Policies for wallet_transactions
CREATE POLICY "Users can view own transactions"
    ON wallet_transactions
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own transactions"
    ON wallet_transactions
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- RLS Policies for gifts
CREATE POLICY "Anyone can view active gifts"
    ON gifts
    FOR SELECT
    TO authenticated, anon
    USING (is_active = true);

-- RLS Policies for user_gifts
CREATE POLICY "Users can view own gifts"
    ON user_gifts
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can purchase gifts"
    ON user_gifts
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- RLS Policies for creator_bonuses
CREATE POLICY "Authors can view own bonuses"
    ON creator_bonuses
    FOR SELECT
    TO authenticated
    USING (auth.uid() = author_id);

-- RLS Policies for user_balances
CREATE POLICY "Users can view own balance"
    ON user_balances
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own balance"
    ON user_balances
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_articles_author_id ON articles(author_id);
CREATE INDEX IF NOT EXISTS idx_articles_created_at ON articles(created_at);
CREATE INDEX IF NOT EXISTS idx_article_likes_article_id ON article_likes(article_id);
CREATE INDEX IF NOT EXISTS idx_article_likes_user_id ON article_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_article_comments_article_id ON article_comments(article_id);
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_user_id ON wallet_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_created_at ON wallet_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_user_gifts_user_id ON user_gifts(user_id);
CREATE INDEX IF NOT EXISTS idx_creator_bonuses_author_id ON creator_bonuses(author_id);

-- Insert sample gifts
INSERT INTO gifts (name, price, icon, description) VALUES
('花束', 100, '🌸', '表達支持的小禮物'),
('火箭', 1000, '🚀', '推動投資組合起飛'),
('黃金', 5000, '🏆', '最高等級的認可');

-- Insert sample articles
INSERT INTO articles (title, author, author_id, summary, full_content, category, read_time, likes_count, comments_count) VALUES
(
    'AI 股票投資策略：如何在科技革命中獲利',
    '投資分析師王小明',
    '00000000-0000-0000-0000-000000000001',
    '探討人工智慧對股市的影響，以及如何選擇相關投資標的。本文深入分析當前AI產業趨勢，提供實用的投資建議。',
    '人工智慧正在改變世界，也在重塑投資市場。作為投資者，我們需要了解這個趨勢並從中獲利。首先，讓我們看看AI產業的現狀...',
    '科技股',
    '5 分鐘',
    245,
    67
),
(
    '綠能轉型：太陽能股票投資機會分析',
    '環保投資專家Lisa',
    '00000000-0000-0000-0000-000000000002',
    '全球綠能政策推動下，太陽能產業迎來黃金發展期。分析主要太陽能公司的投資價值和未來前景。',
    '隨著全球對氣候變化的關注日益增加，綠能產業正迎來前所未有的發展機遇。太陽能作為最重要的可再生能源之一...',
    '綠能',
    '7 分鐘',
    189,
    43
),
(
    '短線交易心法：如何在波動市場中生存',
    '交易員Kevin',
    '00000000-0000-0000-0000-000000000003',
    '分享短線交易的技巧與風險控制策略，適合積極投資者參考。包含實戰案例和心理建設。',
    '短線交易是一門藝術，也是一門科學。在瞬息萬變的市場中，如何保持冷靜並做出正確決策...',
    '短期投機',
    '4 分鐘',
    356,
    89
);

-- Function to update article likes count
CREATE OR REPLACE FUNCTION update_article_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE articles 
        SET likes_count = likes_count + 1,
            updated_at = NOW()
        WHERE id = NEW.article_id;
        
        -- Check for creator bonus milestone
        PERFORM check_creator_bonus(NEW.article_id);
        
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE articles 
        SET likes_count = likes_count - 1,
            updated_at = NOW()
        WHERE id = OLD.article_id;
        
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to check and award creator bonus
CREATE OR REPLACE FUNCTION check_creator_bonus(article_uuid UUID)
RETURNS VOID AS $$
DECLARE
    article_record RECORD;
    milestone INTEGER;
    bonus_amount INTEGER;
BEGIN
    -- Get article details
    SELECT * INTO article_record FROM articles WHERE id = article_uuid;
    
    -- Calculate milestone (every 100 likes)
    milestone := (article_record.likes_count / 100) * 100;
    
    -- Only process if milestone is reached and not already paid
    IF milestone > 0 AND NOT EXISTS (
        SELECT 1 FROM creator_bonuses 
        WHERE article_id = article_uuid AND likes_milestone = milestone
    ) THEN
        bonus_amount := 100; -- 100 NTD per 100 likes
        
        -- Insert bonus record
        INSERT INTO creator_bonuses (article_id, author_id, likes_milestone, bonus_amount)
        VALUES (article_uuid, article_record.author_id, milestone, bonus_amount);
        
        -- Update author's withdrawable amount
        INSERT INTO user_balances (user_id, withdrawable_amount)
        VALUES (article_record.author_id, bonus_amount)
        ON CONFLICT (user_id)
        DO UPDATE SET 
            withdrawable_amount = user_balances.withdrawable_amount + bonus_amount,
            updated_at = NOW();
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to update article comments count
CREATE OR REPLACE FUNCTION update_article_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE articles 
        SET comments_count = comments_count + 1,
            updated_at = NOW()
        WHERE id = NEW.article_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE articles 
        SET comments_count = comments_count - 1,
            updated_at = NOW()
        WHERE id = OLD.article_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
CREATE TRIGGER trigger_update_article_likes_count
    AFTER INSERT OR DELETE ON article_likes
    FOR EACH ROW
    EXECUTE FUNCTION update_article_likes_count();

CREATE TRIGGER trigger_update_article_comments_count
    AFTER INSERT OR DELETE ON article_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_article_comments_count();

-- Insert sample user balances
INSERT INTO user_balances (user_id, balance, withdrawable_amount) VALUES
('00000000-0000-0000-0000-000000000001', 5000, 2500),
('00000000-0000-0000-0000-000000000002', 3200, 1800),
('00000000-0000-0000-0000-000000000003', 7500, 4200);

-- Insert sample wallet transactions
INSERT INTO wallet_transactions (user_id, transaction_type, amount, description, status, payment_method, blockchain_id) VALUES
('00000000-0000-0000-0000-000000000001', 'gift_purchase', -200, '花束 x2 → 科技股挑戰賽', 'confirmed', 'wallet', '0x1234abcd'),
('00000000-0000-0000-0000-000000000001', 'deposit', 1000, 'LINE Pay 儲值', 'confirmed', 'line_pay', '0x5678efgh'),
('00000000-0000-0000-0000-000000000001', 'gift_purchase', -1000, '火箭 x1 → 綠能投資群', 'pending', 'wallet', '0x9abcijkl');