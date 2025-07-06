-- Investment Groups Table
CREATE TABLE IF NOT EXISTS investment_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    host TEXT NOT NULL,
    return_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    entry_fee TEXT NOT NULL,
    member_count INTEGER NOT NULL DEFAULT 0,
    category TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Weekly Rankings Table
CREATE TABLE IF NOT EXISTS weekly_rankings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    return_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Group Members Table
CREATE TABLE IF NOT EXISTS group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES investment_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(group_id, user_id)
);

-- Enable Row Level Security
ALTER TABLE investment_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_rankings ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- RLS Policies for investment_groups
CREATE POLICY "Anyone can view investment groups"
    ON investment_groups
    FOR SELECT
    TO authenticated, anon
    USING (true);

-- RLS Policies for weekly_rankings
CREATE POLICY "Anyone can view weekly rankings"
    ON weekly_rankings
    FOR SELECT
    TO authenticated, anon
    USING (true);

-- RLS Policies for group_members
CREATE POLICY "Users can view group members"
    ON group_members
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can join groups"
    ON group_members
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Insert sample data
INSERT INTO investment_groups (name, host, return_rate, entry_fee, member_count, category) VALUES
('科技股挑戰賽', '投資大師Tom', 18.5, '2 花束 (200 NTD)', 156, '科技股'),
('綠能未來', '環保投資者Lisa', 12.3, '1 火箭 (1000 NTD)', 89, '綠能'),
('短線交易王', '快手Kevin', 25.7, '5 花束 (500 NTD)', 234, '短期投機');

INSERT INTO weekly_rankings (name, return_rate, week_start, week_end) VALUES
('投資大師Tom', 18.5, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE),
('環保投資者Lisa', 12.3, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE),
('快手Kevin', 25.7, CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE);