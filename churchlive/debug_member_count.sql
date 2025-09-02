-- Debug queries to check member count data

-- 1. Check if the new column exists
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'churches' 
AND column_name IN ('member_count', 'member_count_range');

-- 2. Check current data in both columns
SELECT 
  name,
  member_count,
  member_count_range,
  created_at
FROM churches 
ORDER BY created_at DESC
LIMIT 10;

-- 3. Check distribution of member_count values
SELECT 
  CASE 
    WHEN member_count IS NULL THEN 'NULL'
    WHEN member_count = 0 THEN 'ZERO'
    WHEN member_count < 50 THEN 'UNDER_50'
    WHEN member_count BETWEEN 50 AND 99 THEN '50_100'
    WHEN member_count BETWEEN 100 AND 299 THEN '100_300'
    WHEN member_count >= 300 THEN 'OVER_300'
    ELSE 'OTHER'
  END as member_count_category,
  COUNT(*) as count
FROM churches 
GROUP BY 
  CASE 
    WHEN member_count IS NULL THEN 'NULL'
    WHEN member_count = 0 THEN 'ZERO'
    WHEN member_count < 50 THEN 'UNDER_50'
    WHEN member_count BETWEEN 50 AND 99 THEN '50_100'
    WHEN member_count BETWEEN 100 AND 299 THEN '100_300'
    WHEN member_count >= 300 THEN 'OVER_300'
    ELSE 'OTHER'
  END
ORDER BY count DESC;

-- 4. Check distribution of member_count_range values
SELECT 
  member_count_range,
  COUNT(*) as count
FROM churches 
GROUP BY member_count_range
ORDER BY count DESC;

