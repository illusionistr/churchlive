import 'package:equatable/equatable.dart';

class PreviousStream extends Equatable {
  final String id;
  final String churchId;
  final String youtubeVideoId;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final String? duration; // ISO 8601 format (PT1H30M)
  final int? viewCount;
  final String videoUrl;

  const PreviousStream({
    required this.id,
    required this.churchId,
    required this.youtubeVideoId,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.publishedAt,
    this.duration,
    this.viewCount,
    required this.videoUrl,
  });

  /// Formats duration from ISO 8601 (PT1H30M) to readable format (1h 30m)
  String get formattedDuration {
    if (duration == null) return '';

    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration!);

    if (match == null) return '';

    final hours = match.group(1);
    final minutes = match.group(2);
    final seconds = match.group(3);

    final parts = <String>[];

    if (hours != null && hours != '0') {
      parts.add('${hours}h');
    }

    if (minutes != null && minutes != '0') {
      parts.add('${minutes}m');
    } else if (hours != null) {
      parts.add('0m');
    }

    if (parts.isEmpty && seconds != null) {
      parts.add('${seconds}s');
    }

    return parts.join(' ');
  }

  /// Formats view count with K/M suffixes
  String get formattedViewCount {
    if (viewCount == null) return '';

    if (viewCount! >= 1000000) {
      final millions = (viewCount! / 1000000).toStringAsFixed(1);
      return '${millions}M views';
    } else if (viewCount! >= 1000) {
      final thousands = (viewCount! / 1000).toStringAsFixed(1);
      return '${thousands}K views';
    } else {
      return '$viewCount views';
    }
  }

  /// Returns relative time (e.g., "2 weeks ago", "1 month ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays >= 1) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }

  /// Returns formatted publish date (e.g., "Mar 15, 2024")
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[publishedAt.month - 1]} ${publishedAt.day}, ${publishedAt.year}';
  }

  @override
  List<Object?> get props => [
    id,
    churchId,
    youtubeVideoId,
    title,
    description,
    thumbnailUrl,
    publishedAt,
    duration,
    viewCount,
    videoUrl,
  ];
}

