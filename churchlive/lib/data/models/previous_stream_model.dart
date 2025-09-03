import '../../domain/entities/previous_stream.dart';

class PreviousStreamModel extends PreviousStream {
  const PreviousStreamModel({
    required super.id,
    required super.churchId,
    required super.youtubeVideoId,
    required super.title,
    super.description,
    required super.thumbnailUrl,
    required super.publishedAt,
    super.duration,
    super.viewCount,
    required super.videoUrl,
  });

  /// Creates PreviousStreamModel from YouTube API response
  factory PreviousStreamModel.fromYouTubeApi({
    required String churchId,
    required Map<String, dynamic> videoData,
    required Map<String, dynamic> videoDetails,
  }) {
    final snippet = videoData['snippet'] as Map<String, dynamic>;
    final statistics = videoDetails['statistics'] as Map<String, dynamic>?;
    final contentDetails =
        videoDetails['contentDetails'] as Map<String, dynamic>?;

    final videoId = videoData['id']['videoId'] ?? videoData['id'];
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>;

    // Get the best available thumbnail
    String thumbnailUrl = '';
    if (thumbnails.containsKey('maxres')) {
      thumbnailUrl = thumbnails['maxres']['url'];
    } else if (thumbnails.containsKey('high')) {
      thumbnailUrl = thumbnails['high']['url'];
    } else if (thumbnails.containsKey('medium')) {
      thumbnailUrl = thumbnails['medium']['url'];
    } else if (thumbnails.containsKey('default')) {
      thumbnailUrl = thumbnails['default']['url'];
    }

    return PreviousStreamModel(
      id: videoId,
      churchId: churchId,
      youtubeVideoId: videoId,
      title: snippet['title'] ?? 'Untitled Stream',
      description: snippet['description'],
      thumbnailUrl: thumbnailUrl,
      publishedAt: DateTime.parse(snippet['publishedAt']),
      duration: contentDetails?['duration'],
      viewCount: statistics != null
          ? int.tryParse(statistics['viewCount'] ?? '0')
          : null,
      videoUrl: 'https://www.youtube.com/watch?v=$videoId',
    );
  }

  /// Creates PreviousStreamModel from database JSON
  factory PreviousStreamModel.fromJson(Map<String, dynamic> json) {
    return PreviousStreamModel(
      id: json['id'],
      churchId: json['church_id'],
      youtubeVideoId: json['youtube_video_id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      publishedAt: DateTime.parse(json['published_at']),
      duration: json['duration'],
      viewCount: json['view_count'],
      videoUrl:
          json['video_url'] ??
          'https://www.youtube.com/watch?v=${json['youtube_video_id']}',
    );
  }

  /// Converts PreviousStreamModel to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'church_id': churchId,
      'youtube_video_id': youtubeVideoId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'published_at': publishedAt.toIso8601String(),
      'duration': duration,
      'view_count': viewCount,
      'video_url': videoUrl,
    };
  }

  /// Creates a copy with updated fields
  PreviousStreamModel copyWith({
    String? id,
    String? churchId,
    String? youtubeVideoId,
    String? title,
    String? description,
    String? thumbnailUrl,
    DateTime? publishedAt,
    String? duration,
    int? viewCount,
    String? videoUrl,
  }) {
    return PreviousStreamModel(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      duration: duration ?? this.duration,
      viewCount: viewCount ?? this.viewCount,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}

