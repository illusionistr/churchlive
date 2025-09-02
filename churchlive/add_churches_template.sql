-- Template for adding new churches to the database
-- Copy this template and modify the values for each church

INSERT INTO churches (
  name,
  description,
  denomination_id,
  country_id,
  primary_language_id,
  website_url,
  contact_email,
  phone_number,
  address,
  city,
  postal_code,
  latitude,
  longitude,
  timezone,
  verification_status,
  is_active,
  member_count,
  founded_year
) VALUES (
  'Your Church Name Here',
  'Brief description of the church and its mission',
  (SELECT id FROM denominations WHERE name = 'Catholic' LIMIT 1), -- Change denomination
  (SELECT id FROM countries WHERE name = 'United States' LIMIT 1), -- Change country
  (SELECT id FROM languages WHERE name = 'English' LIMIT 1), -- Change language
  'https://yourchurch.com',
  'contact@yourchurch.com',
  '+1-555-123-4567',
  '123 Main Street',
  'Your City',
  '12345',
  40.7128, -- Latitude (get from Google Maps)
  -74.0060, -- Longitude (get from Google Maps)
  'America/New_York', -- Timezone
  'verified', -- or 'pending' or 'rejected'
  true, -- Active church
  500, -- Estimated member count
  1965 -- Year founded (optional)
);

-- Example: Adding a real church
INSERT INTO churches (
  name,
  description,
  denomination_id,
  country_id,
  primary_language_id,
  website_url,
  contact_email,
  phone_number,
  address,
  city,
  postal_code,
  latitude,
  longitude,
  timezone,
  verification_status,
  is_active,
  member_count,
  founded_year
) VALUES (
  'St. Mary Catholic Church',
  'A welcoming Catholic community serving downtown Chicago since 1895',
  (SELECT id FROM denominations WHERE name = 'Catholic' LIMIT 1),
  (SELECT id FROM countries WHERE name = 'United States' LIMIT 1),
  (SELECT id FROM languages WHERE name = 'English' LIMIT 1),
  'https://stmarychicago.org',
  'info@stmarychicago.org',
  '+1-312-555-0123',
  '456 Michigan Avenue',
  'Chicago',
  '60611',
  41.8781,
  -87.6298,
  'America/Chicago',
  'verified',
  true,
  750,
  1895
);