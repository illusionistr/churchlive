-- Step 1: Migrate to simplified live status
-- Copy and paste this into your Supabase SQL Editor

-- 1. Add live status columns to churches table
ALTER TABLE churches 
ADD COLUMN IF NOT EXISTS is_live BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS live_stream_title TEXT,
ADD COLUMN IF NOT EXISTS last_live_check TIMESTAMP WITH TIME ZONE;

-- 2. Copy existing data from live_status to churches (if any exists)
UPDATE churches 
SET 
  is_live = ls.is_live,
  live_stream_title = ls.stream_title,
  last_live_check = ls.last_checked
FROM live_status ls 
WHERE churches.youtube_channel_id = ls.creator_id 
  AND ls.platform = 'youtube';

-- 3. Create index for faster live church queries
CREATE INDEX IF NOT EXISTS idx_churches_is_live ON churches(is_live) WHERE is_live = true;

-- 4. Add some test data to see it working
UPDATE churches 
SET 
  is_live = true,
  live_stream_title = 'Sunday Morning Service - LIVE',
  last_live_check = NOW()
WHERE youtube_channel_id = 'UCJ5v_MCY6GNUBTO8-D3XoAg'; -- Westminster Presbyterian

-- 5. Verify the changes
SELECT 
  name, 
  is_live, 
  live_stream_title, 
  last_live_check,
  youtube_channel_id
FROM churches 
WHERE youtube_channel_id IS NOT NULL
LIMIT 5;

