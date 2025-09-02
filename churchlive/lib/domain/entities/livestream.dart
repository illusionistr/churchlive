import 'package:equatable/equatable.dart';

class Livestream extends Equatable {
  final String id;
  final String churchId;
  final String title;
  final String? description;
  final String? slug;
  final String streamUrl;
  final StreamPlatform platform;
  final String? platformId;
  final String? thumbnailUrl;

  // Scheduling
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;

  // Status and metadata
  final StreamStatus status;
  final bool isFeatured;
  final String? languageId;
  final String? languageName;
  final String? languageCode;
  final int viewerCount;
  final int maxViewers;

  // Recurring streams
  final bool isRecurring;
  final RecurrenceType recurrencePattern;
  final DateTime? recurrenceEndDate;
  final String? parentStreamId;

  // Technical details
  final String? streamQuality;
  final bool isChatEnabled;
  final String? chatUrl;

  // Streaming platform details
  final String? youtubeVideoId;
  final String? vimeoVideoId;
  final String? facebookVideoId;
  final String? customEmbedUrl;
  final bool isLive;
  final int liveViewerCount;
  final int totalViews;

  // Metadata
  final List<String> tags;
  final Map<String, dynamic>? customFields;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Church details (when fetched with church info)
  final String? churchName;
  final String? churchLogoUrl;
  final String? churchCity;
  final String? churchCountry;

  const Livestream({
    required this.id,
    required this.churchId,
    required this.title,
    this.description,
    this.slug,
    required this.streamUrl,
    required this.platform,
    this.platformId,
    this.thumbnailUrl,
    this.scheduledStart,
    this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    required this.status,
    required this.isFeatured,
    this.languageId,
    this.languageName,
    this.languageCode,
    required this.viewerCount,
    required this.maxViewers,
    required this.isRecurring,
    required this.recurrencePattern,
    this.recurrenceEndDate,
    this.parentStreamId,
    this.streamQuality,
    required this.isChatEnabled,
    this.chatUrl,
    this.youtubeVideoId,
    this.vimeoVideoId,
    this.facebookVideoId,
    this.customEmbedUrl,
    this.isLive = false,
    this.liveViewerCount = 0,
    this.totalViews = 0,
    required this.tags,
    this.customFields,
    required this.createdAt,
    required this.updatedAt,
    this.churchName,
    this.churchLogoUrl,
    this.churchCity,
    this.churchCountry,
  });

  @override
  List<Object?> get props => [
    id,
    churchId,
    title,
    description,
    slug,
    streamUrl,
    platform,
    platformId,
    thumbnailUrl,
    scheduledStart,
    scheduledEnd,
    actualStart,
    actualEnd,
    status,
    isFeatured,
    languageId,
    viewerCount,
    maxViewers,
    isRecurring,
    recurrencePattern,
    recurrenceEndDate,
    parentStreamId,
    streamQuality,
    isChatEnabled,
    chatUrl,
    youtubeVideoId,
    vimeoVideoId,
    facebookVideoId,
    customEmbedUrl,
    isLive,
    liveViewerCount,
    totalViews,
    tags,
    customFields,
    createdAt,
    updatedAt,
    churchName,
    churchLogoUrl,
    churchCity,
    churchCountry,
  ];

  bool get isScheduled => status == StreamStatus.scheduled;
  bool get hasEnded => status == StreamStatus.ended;
  bool get isCancelled => status == StreamStatus.cancelled;

  Duration? get duration {
    if (actualStart != null && actualEnd != null) {
      return actualEnd!.difference(actualStart!);
    }
    if (scheduledStart != null && scheduledEnd != null) {
      return scheduledEnd!.difference(scheduledStart!);
    }
    return null;
  }

  Duration? get timeUntilStart {
    if (scheduledStart != null && status == StreamStatus.scheduled) {
      final now = DateTime.now();
      if (scheduledStart!.isAfter(now)) {
        return scheduledStart!.difference(now);
      }
    }
    return null;
  }

  bool get isStartingSoon {
    final timeUntil = timeUntilStart;
    return timeUntil != null && timeUntil.inMinutes <= 15;
  }

  Livestream copyWith({
    String? id,
    String? churchId,
    String? title,
    String? description,
    String? slug,
    String? streamUrl,
    StreamPlatform? platform,
    String? platformId,
    String? thumbnailUrl,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    DateTime? actualStart,
    DateTime? actualEnd,
    StreamStatus? status,
    bool? isFeatured,
    String? languageId,
    String? languageName,
    String? languageCode,
    int? viewerCount,
    int? maxViewers,
    bool? isRecurring,
    RecurrenceType? recurrencePattern,
    DateTime? recurrenceEndDate,
    String? parentStreamId,
    String? streamQuality,
    bool? isChatEnabled,
    String? chatUrl,
    List<String>? tags,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? churchName,
    String? churchLogoUrl,
    String? churchCity,
    String? churchCountry,
  }) {
    return Livestream(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      title: title ?? this.title,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      streamUrl: streamUrl ?? this.streamUrl,
      platform: platform ?? this.platform,
      platformId: platformId ?? this.platformId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      languageId: languageId ?? this.languageId,
      languageName: languageName ?? this.languageName,
      languageCode: languageCode ?? this.languageCode,
      viewerCount: viewerCount ?? this.viewerCount,
      maxViewers: maxViewers ?? this.maxViewers,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      parentStreamId: parentStreamId ?? this.parentStreamId,
      streamQuality: streamQuality ?? this.streamQuality,
      isChatEnabled: isChatEnabled ?? this.isChatEnabled,
      chatUrl: chatUrl ?? this.chatUrl,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      churchName: churchName ?? this.churchName,
      churchLogoUrl: churchLogoUrl ?? this.churchLogoUrl,
      churchCity: churchCity ?? this.churchCity,
      churchCountry: churchCountry ?? this.churchCountry,
    );
  }
}

enum StreamPlatform {
  youtube,
  facebook,
  vimeo,
  custom,
  twitch;

  String get displayName {
    switch (this) {
      case StreamPlatform.youtube:
        return 'YouTube';
      case StreamPlatform.facebook:
        return 'Facebook';
      case StreamPlatform.vimeo:
        return 'Vimeo';
      case StreamPlatform.custom:
        return 'Custom';
      case StreamPlatform.twitch:
        return 'Twitch';
    }
  }

  String get iconAsset {
    switch (this) {
      case StreamPlatform.youtube:
        return 'assets/icons/youtube.svg';
      case StreamPlatform.facebook:
        return 'assets/icons/facebook.svg';
      case StreamPlatform.vimeo:
        return 'assets/icons/vimeo.svg';
      case StreamPlatform.twitch:
        return 'assets/icons/twitch.svg';
      case StreamPlatform.custom:
        return 'assets/icons/stream.svg';
    }
  }
}

enum StreamStatus {
  scheduled,
  live,
  ended,
  cancelled;

  String get displayName {
    switch (this) {
      case StreamStatus.scheduled:
        return 'Scheduled';
      case StreamStatus.live:
        return 'Live';
      case StreamStatus.ended:
        return 'Ended';
      case StreamStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive =>
      this == StreamStatus.live || this == StreamStatus.scheduled;
}

enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'None';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
    }
  }
}
