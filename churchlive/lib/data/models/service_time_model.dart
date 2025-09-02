import '../../domain/entities/service_time.dart';

class ServiceTimeModel extends ServiceTime {
  const ServiceTimeModel({
    required super.id,
    required super.churchId,
    required super.name,
    required super.dayOfWeek,
    required super.time,
    super.description,
    super.isActive,
    super.timezone,
    super.metadata,
  });

  factory ServiceTimeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTimeModel(
      id: json['id'] as String,
      churchId: json['church_id'] as String,
      name: json['name'] as String,
      dayOfWeek: json['day_of_week'] as String,
      time: json['time'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      timezone: json['timezone'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'church_id': churchId,
      'name': name,
      'day_of_week': dayOfWeek,
      'time': time,
      'description': description,
      'is_active': isActive,
      'timezone': timezone,
      'metadata': metadata,
    };
  }

  factory ServiceTimeModel.fromEntity(ServiceTime serviceTime) {
    return ServiceTimeModel(
      id: serviceTime.id,
      churchId: serviceTime.churchId,
      name: serviceTime.name,
      dayOfWeek: serviceTime.dayOfWeek,
      time: serviceTime.time,
      description: serviceTime.description,
      isActive: serviceTime.isActive,
      timezone: serviceTime.timezone,
      metadata: serviceTime.metadata,
    );
  }

  ServiceTime toEntity() {
    return ServiceTime(
      id: id,
      churchId: churchId,
      name: name,
      dayOfWeek: dayOfWeek,
      time: time,
      description: description,
      isActive: isActive,
      timezone: timezone,
      metadata: metadata,
    );
  }
}
