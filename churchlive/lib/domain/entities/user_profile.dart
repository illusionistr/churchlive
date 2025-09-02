import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? countryId;
  final String? countryName;
  final String? countryCode;
  final String? city;
  final String timezone;
  final String? preferredLanguageId;
  final String? preferredLanguageName;
  final String? preferredLanguageCode;
  final DateTime? dateOfBirth;
  final NotificationSettings notificationSettings;
  final PrivacySettings privacySettings;
  final DateTime lastActive;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.countryId,
    this.countryName,
    this.countryCode,
    this.city,
    required this.timezone,
    this.preferredLanguageId,
    this.preferredLanguageName,
    this.preferredLanguageCode,
    this.dateOfBirth,
    required this.notificationSettings,
    required this.privacySettings,
    required this.lastActive,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    bio,
    countryId,
    city,
    timezone,
    preferredLanguageId,
    dateOfBirth,
    notificationSettings,
    privacySettings,
    lastActive,
    isActive,
    createdAt,
    updatedAt,
  ];

  String get displayName => fullName ?? username ?? 'User';

  int? get age {
    if (dateOfBirth != null) {
      final now = DateTime.now();
      int age = now.year - dateOfBirth!.year;
      if (now.month < dateOfBirth!.month ||
          (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
        age--;
      }
      return age;
    }
    return null;
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? countryId,
    String? countryName,
    String? countryCode,
    String? city,
    String? timezone,
    String? preferredLanguageId,
    String? preferredLanguageName,
    String? preferredLanguageCode,
    DateTime? dateOfBirth,
    NotificationSettings? notificationSettings,
    PrivacySettings? privacySettings,
    DateTime? lastActive,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      timezone: timezone ?? this.timezone,
      preferredLanguageId: preferredLanguageId ?? this.preferredLanguageId,
      preferredLanguageName:
          preferredLanguageName ?? this.preferredLanguageName,
      preferredLanguageCode:
          preferredLanguageCode ?? this.preferredLanguageCode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      privacySettings: privacySettings ?? this.privacySettings,
      lastActive: lastActive ?? this.lastActive,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationSettings extends Equatable {
  final bool liveStreams;
  final bool newChurches;
  final bool weeklyDigest;
  final bool pushEnabled;

  const NotificationSettings({
    required this.liveStreams,
    required this.newChurches,
    required this.weeklyDigest,
    required this.pushEnabled,
  });

  factory NotificationSettings.defaultSettings() {
    return const NotificationSettings(
      liveStreams: true,
      newChurches: false,
      weeklyDigest: true,
      pushEnabled: true,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      liveStreams: json['live_streams'] as bool? ?? true,
      newChurches: json['new_churches'] as bool? ?? false,
      weeklyDigest: json['weekly_digest'] as bool? ?? true,
      pushEnabled: json['push_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'live_streams': liveStreams,
      'new_churches': newChurches,
      'weekly_digest': weeklyDigest,
      'push_enabled': pushEnabled,
    };
  }

  @override
  List<Object?> get props => [
    liveStreams,
    newChurches,
    weeklyDigest,
    pushEnabled,
  ];

  NotificationSettings copyWith({
    bool? liveStreams,
    bool? newChurches,
    bool? weeklyDigest,
    bool? pushEnabled,
  }) {
    return NotificationSettings(
      liveStreams: liveStreams ?? this.liveStreams,
      newChurches: newChurches ?? this.newChurches,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      pushEnabled: pushEnabled ?? this.pushEnabled,
    );
  }
}

class PrivacySettings extends Equatable {
  final ProfileVisibility profileVisibility;
  final bool showFavorites;
  final bool showActivity;

  const PrivacySettings({
    required this.profileVisibility,
    required this.showFavorites,
    required this.showActivity,
  });

  factory PrivacySettings.defaultSettings() {
    return const PrivacySettings(
      profileVisibility: ProfileVisibility.public,
      showFavorites: true,
      showActivity: false,
    );
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisibility: ProfileVisibility.fromString(
        json['profile_visibility'] as String? ?? 'public',
      ),
      showFavorites: json['show_favorites'] as bool? ?? true,
      showActivity: json['show_activity'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_visibility': profileVisibility.value,
      'show_favorites': showFavorites,
      'show_activity': showActivity,
    };
  }

  @override
  List<Object?> get props => [profileVisibility, showFavorites, showActivity];

  PrivacySettings copyWith({
    ProfileVisibility? profileVisibility,
    bool? showFavorites,
    bool? showActivity,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      showFavorites: showFavorites ?? this.showFavorites,
      showActivity: showActivity ?? this.showActivity,
    );
  }
}

enum ProfileVisibility {
  public,
  private,
  friends;

  String get value {
    switch (this) {
      case ProfileVisibility.public:
        return 'public';
      case ProfileVisibility.private:
        return 'private';
      case ProfileVisibility.friends:
        return 'friends';
    }
  }

  String get displayName {
    switch (this) {
      case ProfileVisibility.public:
        return 'Public';
      case ProfileVisibility.private:
        return 'Private';
      case ProfileVisibility.friends:
        return 'Friends Only';
    }
  }

  static ProfileVisibility fromString(String value) {
    switch (value.toLowerCase()) {
      case 'public':
        return ProfileVisibility.public;
      case 'private':
        return ProfileVisibility.private;
      case 'friends':
        return ProfileVisibility.friends;
      default:
        return ProfileVisibility.public;
    }
  }
}
