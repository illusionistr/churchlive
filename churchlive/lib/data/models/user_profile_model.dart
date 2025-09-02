import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    super.username,
    super.fullName,
    super.avatarUrl,
    super.bio,
    super.countryId,
    super.countryName,
    super.countryCode,
    super.city,
    required super.timezone,
    super.preferredLanguageId,
    super.preferredLanguageName,
    super.preferredLanguageCode,
    super.dateOfBirth,
    required super.notificationSettings,
    required super.privacySettings,
    required super.lastActive,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      countryId: json['country_id'] as String?,
      countryName: json['country_name'] as String?,
      countryCode: json['country_code'] as String?,
      city: json['city'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      preferredLanguageId: json['preferred_language_id'] as String?,
      preferredLanguageName: json['preferred_language_name'] as String?,
      preferredLanguageCode: json['preferred_language_code'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      notificationSettings: json['notification_settings'] != null
          ? NotificationSettings.fromJson(
              json['notification_settings'] as Map<String, dynamic>,
            )
          : NotificationSettings.defaultSettings(),
      privacySettings: json['privacy_settings'] != null
          ? PrivacySettings.fromJson(
              json['privacy_settings'] as Map<String, dynamic>,
            )
          : PrivacySettings.defaultSettings(),
      lastActive: DateTime.parse(json['last_active'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'country_id': countryId,
      'city': city,
      'timezone': timezone,
      'preferred_language_id': preferredLanguageId,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'notification_settings': notificationSettings.toJson(),
      'privacy_settings': privacySettings.toJson(),
      'last_active': lastActive.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromEntity(UserProfile userProfile) {
    return UserProfileModel(
      id: userProfile.id,
      username: userProfile.username,
      fullName: userProfile.fullName,
      avatarUrl: userProfile.avatarUrl,
      bio: userProfile.bio,
      countryId: userProfile.countryId,
      countryName: userProfile.countryName,
      countryCode: userProfile.countryCode,
      city: userProfile.city,
      timezone: userProfile.timezone,
      preferredLanguageId: userProfile.preferredLanguageId,
      preferredLanguageName: userProfile.preferredLanguageName,
      preferredLanguageCode: userProfile.preferredLanguageCode,
      dateOfBirth: userProfile.dateOfBirth,
      notificationSettings: userProfile.notificationSettings,
      privacySettings: userProfile.privacySettings,
      lastActive: userProfile.lastActive,
      isActive: userProfile.isActive,
      createdAt: userProfile.createdAt,
      updatedAt: userProfile.updatedAt,
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
      bio: bio,
      countryId: countryId,
      countryName: countryName,
      countryCode: countryCode,
      city: city,
      timezone: timezone,
      preferredLanguageId: preferredLanguageId,
      preferredLanguageName: preferredLanguageName,
      preferredLanguageCode: preferredLanguageCode,
      dateOfBirth: dateOfBirth,
      notificationSettings: notificationSettings,
      privacySettings: privacySettings,
      lastActive: lastActive,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
