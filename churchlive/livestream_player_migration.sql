-- Migration: Add livestream player features
-- Run this SQL in your Supabase SQL editor

-- Add streaming platform URLs to churches table
ALTER TABLE churches 
ADD COLUMN IF NOT EXISTS youtube_channel_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS youtube_channel_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS vimeo_channel_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS vimeo_channel_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS facebook_page_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS facebook_page_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS custom_stream_url VARCHAR(500);

-- Update livestreams table to include more streaming details
ALTER TABLE livestreams
ADD COLUMN IF NOT EXISTS youtube_video_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS vimeo_video_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS facebook_video_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS custom_embed_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS thumbnail_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS is_live BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS live_viewer_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_views INTEGER DEFAULT 0;

-- Create stream views tracking table (anonymous device tracking)
CREATE TABLE IF NOT EXISTS stream_views (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  device_id VARCHAR(255) NOT NULL, -- Anonymous device identifier
  church_id UUID REFERENCES churches(id) ON DELETE CASCADE,
  livestream_id UUID REFERENCES livestreams(id) ON DELETE CASCADE,
  platform VARCHAR(50) NOT NULL, -- 'youtube', 'vimeo', 'facebook', 'custom'
  viewed_at TIMESTAMP DEFAULT NOW(),
  duration_seconds INTEGER DEFAULT 0,
  quality VARCHAR(20), -- '720p', '1080p', etc.
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_stream_views_church_id ON stream_views(church_id);
CREATE INDEX IF NOT EXISTS idx_stream_views_device_id ON stream_views(device_id);
CREATE INDEX IF NOT EXISTS idx_stream_views_viewed_at ON stream_views(viewed_at);
CREATE INDEX IF NOT EXISTS idx_livestreams_is_live ON livestreams(is_live);
CREATE INDEX IF NOT EXISTS idx_livestreams_scheduled_start ON livestreams(scheduled_start);

-- Add some sample streaming data to existing churches
UPDATE churches 
SET 
  youtube_channel_id = 'UC_sample_channel_id_1',
  youtube_channel_url = 'https://www.youtube.com/channel/UC_sample_channel_id_1'
WHERE id = (SELECT id FROM churches WHERE name ILIKE '%catholic%' LIMIT 1);

UPDATE churches 
SET 
  youtube_channel_id = 'UC_sample_channel_id_2',
  youtube_channel_url = 'https://www.youtube.com/channel/UC_sample_channel_id_2'
WHERE id = (SELECT id FROM churches WHERE name ILIKE '%baptist%' LIMIT 1);

-- Add sample livestreams with streaming details
INSERT INTO livestreams (
  church_id,
  title,
  description,
  platform,
  stream_url,
  youtube_video_id,
  thumbnail_url,
  scheduled_start,
  scheduled_end,
  status,
  is_live,
  live_viewer_count,
  is_featured,
  language_id,
  created_at
) VALUES 
(
  (SELECT id FROM churches WHERE name ILIKE '%catholic%' LIMIT 1),
  'Sunday Morning Worship - Live',
  'Join us for our weekly Sunday morning worship service',
  'youtube',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  'dQw4w9WgXcQ',
  'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
  NOW() + INTERVAL '1 hour',
  NOW() + INTERVAL '2 hours',
  'live',
  true,
  127,
  true,
  (SELECT id FROM languages WHERE name = 'English' LIMIT 1),
  NOW()
),
(
  (SELECT id FROM churches WHERE name ILIKE '%baptist%' LIMIT 1),
  'Evening Prayer Service',
  'Peaceful evening prayer and reflection',
  'youtube', 
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  'dQw4w9WgXcQ',
  'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
  NOW() + INTERVAL '3 hours',
  NOW() + INTERVAL '4 hours',
  'scheduled',
  false,
  0,
  true,
  (SELECT id FROM languages WHERE name = 'English' LIMIT 1),
  NOW()
);

-- Verify the updates
SELECT 
  c.name,
  c.youtube_channel_id,
  l.title,
  l.is_live,
  l.live_viewer_count,
  l.status
FROM churches c
LEFT JOIN livestreams l ON c.id = l.church_id
WHERE c.youtube_channel_id IS NOT NULL
ORDER BY c.name;