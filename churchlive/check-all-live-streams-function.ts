// Supabase Edge Function: check-all-live-streams
// This code should be deployed as an Edge Function in your Supabase project

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const YT_API_KEY = Deno.env.get("YOUTUBE_API_KEY")!;

Deno.serve(async (req) => {
  try {
    console.log("Starting batch live stream check...");

    // Get all churches with YouTube channels and auto-detection enabled
    const { data: churches, error } = await supabase
      .from('churches')
      .select('id, name, youtube_channel_id, youtube_channel_url')
      .not('youtube_channel_id', 'is', null)
      .eq('auto_live_detection', true);

    if (error) {
      console.error("Error fetching churches:", error);
      throw error;
    }

    console.log(`Found ${churches?.length || 0} churches to check`);

    const results = [];
    
    for (const church of churches || []) {
      try {
        console.log(`Checking ${church.name} (${church.youtube_channel_id})`);

        // Check if the channel is live using YouTube API directly
        const url = new URL("https://www.googleapis.com/youtube/v3/search");
        url.searchParams.set("part", "snippet");
        url.searchParams.set("channelId", church.youtube_channel_id);
        url.searchParams.set("eventType", "live");
        url.searchParams.set("type", "video");
        url.searchParams.set("key", YT_API_KEY);

        const response = await fetch(url.toString());
        const data = await response.json();

        const isLive = data.items && data.items.length > 0;
        const liveVideo = data.items?.[0];

        console.log(`${church.name} is ${isLive ? 'LIVE' : 'not live'}`);

        // Update live_status table
        const { error: upsertError } = await supabase
          .from("live_status")
          .upsert({
            creator_id: church.youtube_channel_id,
            platform: "youtube",
            is_live: isLive,
            last_checked: new Date().toISOString(),
            stream_title: liveVideo?.snippet?.title || null,
            stream_url: liveVideo ? `https://www.youtube.com/watch?v=${liveVideo.id.videoId}` : null,
            viewer_count: 0 // YouTube API v3 doesn't provide live viewer count in search
          });

        if (upsertError) {
          console.error(`Error updating live status for ${church.name}:`, upsertError);
        }

        // If church is live, ensure there's a livestream record
        if (isLive && liveVideo) {
          await ensureLivestreamRecord(church, liveVideo);
        }

        results.push({
          church_id: church.id,
          church_name: church.name,
          channel_id: church.youtube_channel_id,
          is_live: isLive,
          stream_title: liveVideo?.snippet?.title || null,
          success: true
        });
        
      } catch (err) {
        console.error(`Error checking ${church.name}:`, err);
        results.push({
          church_id: church.id,
          church_name: church.name,
          channel_id: church.youtube_channel_id,
          error: err.message,
          success: false
        });
      }
    }

    const liveCount = results.filter(r => r.is_live).length;
    console.log(`Batch check completed. ${liveCount} churches are live.`);

    return new Response(JSON.stringify({ 
      success: true, 
      checked: churches?.length || 0,
      live_count: liveCount,
      results,
      timestamp: new Date().toISOString()
    }), {
      headers: { "Content-Type": "application/json" },
    });

  } catch (err) {
    console.error("Batch check failed:", err);
    return new Response(JSON.stringify({ 
      error: err.message,
      timestamp: new Date().toISOString()
    }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

async function ensureLivestreamRecord(church: any, liveVideo: any) {
  try {
    // Check if there's already a live stream record for this church
    const { data: existingStream } = await supabase
      .from('livestreams')
      .select('id')
      .eq('church_id', church.id)
      .eq('youtube_video_id', liveVideo.id.videoId)
      .single();

    if (!existingStream) {
      // Create new livestream record
      const { error } = await supabase
        .from('livestreams')
        .insert({
          church_id: church.id,
          title: liveVideo.snippet.title,
          description: liveVideo.snippet.description || '',
          platform: 'youtube',
          status: 'live',
          youtube_video_id: liveVideo.id.videoId,
          is_live: true,
          stream_url: `https://www.youtube.com/watch?v=${liveVideo.id.videoId}`,
          scheduled_start: new Date().toISOString(),
          thumbnail_url: liveVideo.snippet.thumbnails?.medium?.url || liveVideo.snippet.thumbnails?.default?.url
        });

      if (error) {
        console.error(`Error creating livestream record for ${church.name}:`, error);
      } else {
        console.log(`Created livestream record for ${church.name}`);
      }
    }
  } catch (err) {
    console.error(`Error ensuring livestream record for ${church.name}:`, err);
  }
}


