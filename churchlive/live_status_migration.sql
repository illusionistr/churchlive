-- Migration: Add live status tracking system
-- This should be run in Supabase SQL Editor

-- 1. Create live_status table to track real-time status
CREATE TABLE IF NOT EXISTS live_status (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  creator_id TEXT NOT NULL, -- This will be the church's YouTube channel ID
  platform TEXT NOT NULL DEFAULT 'youtube',
  is_live BOOLEAN NOT NULL DEFAULT false,
  last_checked TIMESTAMP WITH TIME ZONE DEFAULT now(),
  stream_title TEXT,
  stream_url TEXT,
  viewer_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Ensure one record per creator per platform
  UNIQUE(creator_id, platform)
);

-- 2. Add YouTube channel tracking to churches table
ALTER TABLE churches 
ADD COLUMN IF NOT EXISTS youtube_channel_id TEXT,
ADD COLUMN IF NOT EXISTS youtube_channel_url TEXT,
ADD COLUMN IF NOT EXISTS auto_live_detection BOOLEAN DEFAULT true;

-- 3. Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_live_status_platform_live ON live_status(platform, is_live);
CREATE INDEX IF NOT EXISTS idx_live_status_last_checked ON live_status(last_checked);
CREATE INDEX IF NOT EXISTS idx_churches_youtube_channel ON churches(youtube_channel_id) 
WHERE youtube_channel_id IS NOT NULL;

-- 4. Create updated_at trigger for live_status
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_live_status_updated_at 
    BEFORE UPDATE ON live_status 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 5. Add some sample YouTube channel IDs to existing churches (optional)
-- You can manually add real channel IDs later
UPDATE churches 
SET 
  youtube_channel_id = CASE 
    WHEN name ILIKE '%hillsong%' THEN 'UC8RJCELLdnZx8F-k0ZMHvmg'
    WHEN name ILIKE '%elevation%' THEN 'UCuPgdqQKpq4T4zeqmTelnFg'
    WHEN name ILIKE '%bethel%' THEN 'UC7wUSGCdB-lbXpYNZKkDy5w'
    ELSE NULL
  END,
  youtube_channel_url = CASE 
    WHEN name ILIKE '%hillsong%' THEN 'https://www.youtube.com/c/HillsongChurch'
    WHEN name ILIKE '%elevation%' THEN 'https://www.youtube.com/c/ElevationChurch'
    WHEN name ILIKE '%bethel%' THEN 'https://www.youtube.com/c/BethelChurch'
    ELSE NULL
  END
WHERE name ILIKE '%hillsong%' OR name ILIKE '%elevation%' OR name ILIKE '%bethel%';

-- 6. Enable RLS on live_status table
ALTER TABLE live_status ENABLE ROW LEVEL SECURITY;

-- 7. Create RLS policies for live_status (allow public read access)
CREATE POLICY "Allow public read access to live_status" ON live_status
    FOR SELECT USING (true);

CREATE POLICY "Allow service role to manage live_status" ON live_status
    FOR ALL USING (auth.role() = 'service_role');


