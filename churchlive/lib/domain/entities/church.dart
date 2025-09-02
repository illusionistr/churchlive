import 'package:equatable/equatable.dart';

class Church extends Equatable {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? denominationId;
  final String? denominationName;
  final String? countryId;
  final String? countryName;
  final String? countryCode;
  final String? city;
  final String? address;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String timezone;
  final String? primaryLanguageId;
  final String? primaryLanguageName;
  final String? primaryLanguageCode;
  final String? websiteUrl;
  final String? contactEmail;
  final String? phoneNumber;
  final String? logoUrl;
  final String? coverImageUrl;
  final ChurchVerificationStatus verificationStatus;
  final bool isActive;
  final int memberCount; // Keep for backward compatibility
  final String? memberCountRange; // New range-based member count
  final int? foundedYear;
  final Map<String, dynamic>? socialLinks;
  final Map<String, dynamic>? streamingSchedule;

  // YouTube integration fields
  final String? youtubeChannelId;
  final String? youtubeChannelUrl;
  final bool autoLiveDetection;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed fields
  final double averageRating;
  final int reviewCount;
  final int liveStreamsCount;
  final int followersCount;

  // Live status fields
  final bool isCurrentlyLive;
  final String? liveStreamTitle;
  final String? liveStreamUrl;
  final DateTime? lastLiveCheck;

  const Church({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.denominationId,
    this.denominationName,
    this.countryId,
    this.countryName,
    this.countryCode,
    this.city,
    this.address,
    this.postalCode,
    this.latitude,
    this.longitude,
    required this.timezone,
    this.primaryLanguageId,
    this.primaryLanguageName,
    this.primaryLanguageCode,
    this.websiteUrl,
    this.contactEmail,
    this.phoneNumber,
    this.logoUrl,
    this.coverImageUrl,
    required this.verificationStatus,
    required this.isActive,
    required this.memberCount,
    this.memberCountRange,
    this.foundedYear,
    this.socialLinks,
    this.streamingSchedule,
    this.youtubeChannelId,
    this.youtubeChannelUrl,
    this.autoLiveDetection = true,
    required this.createdAt,
    required this.updatedAt,
    required this.averageRating,
    required this.reviewCount,
    required this.liveStreamsCount,
    required this.followersCount,
    this.isCurrentlyLive = false,
    this.liveStreamTitle,
    this.liveStreamUrl,
    this.lastLiveCheck,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    denominationId,
    countryId,
    city,
    address,
    postalCode,
    latitude,
    longitude,
    timezone,
    primaryLanguageId,
    websiteUrl,
    contactEmail,
    phoneNumber,
    logoUrl,
    coverImageUrl,
    verificationStatus,
    isActive,
    memberCount,
    memberCountRange,
    foundedYear,
    socialLinks,
    streamingSchedule,
    youtubeChannelId,
    youtubeChannelUrl,
    autoLiveDetection,
    createdAt,
    updatedAt,
    averageRating,
    reviewCount,
    liveStreamsCount,
    followersCount,
    isCurrentlyLive,
    liveStreamTitle,
    liveStreamUrl,
    lastLiveCheck,
  ];

  Church copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? denominationId,
    String? denominationName,
    String? countryId,
    String? countryName,
    String? countryCode,
    String? city,
    String? address,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? timezone,
    String? primaryLanguageId,
    String? primaryLanguageName,
    String? primaryLanguageCode,
    String? websiteUrl,
    String? contactEmail,
    String? phoneNumber,
    String? logoUrl,
    String? coverImageUrl,
    ChurchVerificationStatus? verificationStatus,
    bool? isActive,
    int? memberCount,
    String? memberCountRange,
    int? foundedYear,
    Map<String, dynamic>? socialLinks,
    Map<String, dynamic>? streamingSchedule,
    String? youtubeChannelId,
    String? youtubeChannelUrl,
    bool? autoLiveDetection,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averageRating,
    int? reviewCount,
    int? liveStreamsCount,
    int? followersCount,
    bool? isCurrentlyLive,
    String? liveStreamTitle,
    String? liveStreamUrl,
    DateTime? lastLiveCheck,
  }) {
    return Church(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      denominationId: denominationId ?? this.denominationId,
      denominationName: denominationName ?? this.denominationName,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      primaryLanguageId: primaryLanguageId ?? this.primaryLanguageId,
      primaryLanguageName: primaryLanguageName ?? this.primaryLanguageName,
      primaryLanguageCode: primaryLanguageCode ?? this.primaryLanguageCode,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isActive: isActive ?? this.isActive,
      memberCount: memberCount ?? this.memberCount,
      memberCountRange: memberCountRange ?? this.memberCountRange,
      foundedYear: foundedYear ?? this.foundedYear,
      socialLinks: socialLinks ?? this.socialLinks,
      streamingSchedule: streamingSchedule ?? this.streamingSchedule,
      youtubeChannelId: youtubeChannelId ?? this.youtubeChannelId,
      youtubeChannelUrl: youtubeChannelUrl ?? this.youtubeChannelUrl,
      autoLiveDetection: autoLiveDetection ?? this.autoLiveDetection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      liveStreamsCount: liveStreamsCount ?? this.liveStreamsCount,
      followersCount: followersCount ?? this.followersCount,
      isCurrentlyLive: isCurrentlyLive ?? this.isCurrentlyLive,
      liveStreamTitle: liveStreamTitle ?? this.liveStreamTitle,
      liveStreamUrl: liveStreamUrl ?? this.liveStreamUrl,
      lastLiveCheck: lastLiveCheck ?? this.lastLiveCheck,
    );
  }
}

enum ChurchVerificationStatus {
  unverified,
  pending,
  verified,
  rejected;

  String get displayName {
    switch (this) {
      case ChurchVerificationStatus.unverified:
        return 'Unverified';
      case ChurchVerificationStatus.pending:
        return 'Pending';
      case ChurchVerificationStatus.verified:
        return 'Verified';
      case ChurchVerificationStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isVerified => this == ChurchVerificationStatus.verified;
}
