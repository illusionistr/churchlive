# Supabase Database Setup Guide for ChurchLive

This guide will help you set up your Supabase database for the ChurchLive app.

## Prerequisites

1. A Supabase account and project
2. Access to the Supabase SQL Editor
3. Basic understanding of SQL

## Setup Steps

### 1. Create the Database Schema

1. Open your Supabase project dashboard
2. Go to the **SQL Editor** tab
3. Copy and paste the contents of `supabase_schema.sql`
4. Click **Run** to execute the schema

This will create:
- All necessary tables with proper relationships
- Custom types and enums
- Indexes for optimal performance
- Triggers for automatic timestamp updates
- Seed data for countries, languages, and denominations

### 2. Set Up Row Level Security (RLS)

1. In the SQL Editor, create a new query
2. Copy and paste the contents of `supabase_rls_policies.sql`
3. Click **Run** to execute the policies

This will:
- Enable RLS on sensitive tables
- Create security policies for data access control
- Set up helper functions for permission checking
- Create triggers for user lifecycle management
- Create useful views for common queries

### 3. Configure Authentication

1. Go to **Authentication** → **Settings** in your Supabase dashboard
2. Enable the authentication providers you want:
   - Email/Password (recommended)
   - Google OAuth (recommended)
   - Apple OAuth (for iOS users)
3. Configure email templates if using email auth
4. Set up redirect URLs for your app

### 4. Set Up Storage (Optional)

If you plan to store church logos and cover images in Supabase:

1. Go to **Storage** in your Supabase dashboard
2. Create a new bucket called `church-images`
3. Set up storage policies:

```sql
-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload images" ON storage.objects
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Allow public access to view images
CREATE POLICY "Public can view images" ON storage.objects
FOR SELECT USING (bucket_id = 'church-images');

-- Allow users to update their own church images (if they're admins)
CREATE POLICY "Church admins can update images" ON storage.objects
FOR UPDATE USING (
    auth.role() = 'authenticated' AND
    EXISTS (
        SELECT 1 FROM church_admins ca
        JOIN churches c ON c.id = ca.church_id
        WHERE ca.user_id = auth.uid()
        AND ca.is_active = true
        AND (name LIKE c.slug || '%' OR name LIKE c.id::text || '%')
    )
);
```

### 5. API Configuration

1. Go to **Settings** → **API** in your Supabase dashboard
2. Note down your:
   - Project URL
   - Anon (public) key
   - Service role key (keep this secure!)

These will be needed in your Flutter app configuration.

## Database Schema Overview

### Core Tables

- **churches**: Main church information
- **livestreams**: Stream details and scheduling
- **profiles**: User profiles (extends auth.users)
- **countries**: Normalized country data
- **languages**: Normalized language data
- **denominations**: Church denominations

### Relationship Tables

- **church_languages**: Many-to-many church-language relationships
- **user_favorites**: User's favorite churches
- **user_stream_bookmarks**: User's bookmarked streams
- **church_admins**: Church administration permissions

### Activity Tables

- **stream_views**: Stream viewing analytics
- **church_reviews**: Church ratings and reviews
- **stream_chat_messages**: Stream chat (if implementing custom chat)
- **notifications**: User notifications
- **analytics_events**: App usage analytics

## Important Features

### 1. Automatic Slugs
Churches automatically get URL-friendly slugs generated from their names.

### 2. Stream Status Management
Streams automatically transition between states based on scheduling:
- `scheduled` → `live` → `ended`

### 3. User Profile Creation
User profiles are automatically created when users sign up through the authentication trigger.

### 4. Data Privacy
RLS policies ensure users can only access data they're authorized to see.

### 5. Soft Deletions
Some data (like chat messages) is anonymized rather than deleted to maintain data integrity.

## Useful Views

- **church_details**: Churches with computed fields (ratings, live stream counts)
- **upcoming_streams**: Scheduled and live streams with church information

## Testing the Setup

After running the setup, you can test with some sample data:

```sql
-- Insert a test church
INSERT INTO churches (name, description, country_id, primary_language_id)
SELECT 
    'Sample Community Church',
    'A welcoming church community',
    c.id,
    l.id
FROM countries c, languages l
WHERE c.code = 'US' AND l.code = 'en';

-- Insert a test livestream
INSERT INTO livestreams (
    church_id, 
    title, 
    description, 
    stream_url, 
    platform, 
    platform_id,
    scheduled_start,
    status
)
SELECT 
    c.id,
    'Sunday Morning Service',
    'Join us for worship and fellowship',
    'https://youtube.com/watch?v=example',
    'youtube',
    'example',
    now() + interval '1 day',
    'scheduled'
FROM churches c
WHERE c.name = 'Sample Community Church';
```

## Next Steps

1. Set up your Flutter app with Supabase integration
2. Implement authentication flows
3. Create UI for browsing churches and streams
4. Add filtering and search functionality
5. Implement real-time updates for live streams

## Troubleshooting

### Common Issues

1. **RLS Policy Errors**: Make sure you're running the RLS setup after the main schema
2. **Permission Denied**: Check that your API keys are correctly configured
3. **Trigger Errors**: Ensure the auth.users table exists (it's created automatically by Supabase)

### Useful Queries for Debugging

```sql
-- Check if tables were created
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';

-- View sample data
SELECT * FROM church_details LIMIT 5;
SELECT * FROM upcoming_streams LIMIT 5;
```

## Security Notes

- Never expose your service role key in client-side code
- Regularly review and audit RLS policies
- Monitor for unusual access patterns
- Keep backups of your database
- Test permissions thoroughly before deploying

For more information, refer to the [Supabase documentation](https://supabase.com/docs).