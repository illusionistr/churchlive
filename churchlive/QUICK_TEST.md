# 🧪 Quick Test Guide

If you're getting Supabase initialization errors, follow these steps to debug:

## ✅ **Step 1: Verify Your Supabase Credentials**

Check your `lib/core/constants/environment.dart`:

```dart
// These should be your actual values from Supabase dashboard
static const String devSupabaseUrl = 'https://your-project-id.supabase.co';
static const String devSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

**To get these values:**
1. Go to [supabase.com](https://supabase.com)
2. Open your project dashboard
3. Go to **Settings → API**
4. Copy **Project URL** and **anon public** key

## ✅ **Step 2: Test Supabase Connection**

You can test your connection by visiting this URL in your browser:
```
https://your-project-id.supabase.co/rest/v1/
```

You should see a JSON response with API info.

## ✅ **Step 3: Check Your Database**

1. Go to **Table Editor** in Supabase
2. Make sure you have these tables:
   - `countries`
   - `languages`
   - `denominations`
   - `churches`
   - `livestreams`

If not, run the SQL scripts:
1. `supabase_schema.sql` (creates tables)
2. `supabase_rls_policies.sql` (sets up security) 
3. `dummy_data_simple.sql` (adds sample data)

## ✅ **Step 4: Test Without Database (Debug Mode)**

If you want to test the app UI without database connection, you can temporarily disable Supabase:

1. Comment out the Supabase initialization in `lib/injection_container.dart`:

```dart
// await SupabaseService.instance.initialize();
// getIt.registerSingleton<SupabaseService>(SupabaseService.instance);
```

2. The app will show error states but you can see the UI structure.

## 🔍 **Common Errors & Solutions**

### Error: "Failed to initialize Supabase"
- **Cause**: Wrong URL or API key
- **Solution**: Double-check your credentials from Supabase dashboard

### Error: "Network error" 
- **Cause**: Internet connection or firewall
- **Solution**: Check internet, try mobile hotspot

### Error: "Invalid API key"
- **Cause**: Wrong anon key or expired project
- **Solution**: Regenerate API key in Supabase dashboard

### Error: "Project not found"
- **Cause**: Wrong project URL
- **Solution**: Verify URL format: `https://project-id.supabase.co`

## 🚀 **Success Indicators**

When everything works, you should see:
1. App launches without errors
2. Splash screen appears
3. Denomination selection page shows
4. After selecting denomination, home page shows churches
5. Console logs show: "Supabase initialized successfully"

## 📱 **Current App Behavior**

The app now has better error handling:
- Shows detailed error messages
- Provides guidance for setup
- Graceful fallbacks for missing data
- Refresh button to retry initialization

If you're still having issues, share the exact error message from the console!