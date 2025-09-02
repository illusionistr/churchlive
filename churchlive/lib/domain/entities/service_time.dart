import 'package:equatable/equatable.dart';

class ServiceTime extends Equatable {
  final String id;
  final String churchId;
  final String name;
  final String dayOfWeek;
  final String time;
  final String? description;
  final bool isActive;
  final String? timezone;
  final Map<String, dynamic>? metadata;

  const ServiceTime({
    required this.id,
    required this.churchId,
    required this.name,
    required this.dayOfWeek,
    required this.time,
    this.description,
    this.isActive = true,
    this.timezone,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    churchId,
    name,
    dayOfWeek,
    time,
    description,
    isActive,
    timezone,
    metadata,
  ];

  ServiceTime copyWith({
    String? id,
    String? churchId,
    String? name,
    String? dayOfWeek,
    String? time,
    String? description,
    bool? isActive,
    String? timezone,
    Map<String, dynamic>? metadata,
  }) {
    return ServiceTime(
      id: id ?? this.id,
      churchId: churchId ?? this.churchId,
      name: name ?? this.name,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      time: time ?? this.time,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      timezone: timezone ?? this.timezone,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get display name for day of week
  String get dayDisplayName {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return 'Monday';
      case 'tuesday':
        return 'Tuesday';
      case 'wednesday':
        return 'Wednesday';
      case 'thursday':
        return 'Thursday';
      case 'friday':
        return 'Friday';
      case 'saturday':
        return 'Saturday';
      case 'sunday':
        return 'Sunday';
      default:
        return dayOfWeek;
    }
  }

  /// Get short display name for day of week
  String get dayShortName {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      case 'sunday':
        return 'Sun';
      default:
        return dayOfWeek.substring(0, 3);
    }
  }

  /// Get day of week as number (1 = Monday, 7 = Sunday)
  int get dayNumber {
    switch (dayOfWeek.toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 0;
    }
  }
}
