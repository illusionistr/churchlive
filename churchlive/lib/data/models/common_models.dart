import '../../domain/entities/common.dart';

class CountryModel extends Country {
  const CountryModel({
    required super.id,
    required super.name,
    required super.code,
    required super.createdAt,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CountryModel.fromEntity(Country country) {
    return CountryModel(
      id: country.id,
      name: country.name,
      code: country.code,
      createdAt: country.createdAt,
    );
  }

  Country toEntity() {
    return Country(id: id, name: name, code: code, createdAt: createdAt);
  }
}

class LanguageModel extends Language {
  const LanguageModel({
    required super.id,
    required super.name,
    required super.code,
    required super.createdAt,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LanguageModel.fromEntity(Language language) {
    return LanguageModel(
      id: language.id,
      name: language.name,
      code: language.code,
      createdAt: language.createdAt,
    );
  }

  Language toEntity() {
    return Language(id: id, name: name, code: code, createdAt: createdAt);
  }
}

class DenominationModel extends Denomination {
  const DenominationModel({
    required super.id,
    required super.name,
    super.description,
    required super.createdAt,
    super.clickCount = 0,
  });

  factory DenominationModel.fromJson(Map<String, dynamic> json) {
    return DenominationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      clickCount: json['click_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'click_count': clickCount,
    };
  }

  factory DenominationModel.fromEntity(Denomination denomination) {
    return DenominationModel(
      id: denomination.id,
      name: denomination.name,
      description: denomination.description,
      createdAt: denomination.createdAt,
      clickCount: denomination.clickCount,
    );
  }

  Denomination toEntity() {
    return Denomination(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      clickCount: clickCount,
    );
  }
}

class PaginatedResultModel<T> extends PaginatedResult<T> {
  const PaginatedResultModel({
    required super.items,
    required super.currentPage,
    required super.totalPages,
    required super.totalItems,
    required super.hasNextPage,
    required super.hasPreviousPage,
  });

  factory PaginatedResultModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return PaginatedResultModel(
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      hasNextPage: json['has_next_page'] as bool,
      hasPreviousPage: json['has_previous_page'] as bool,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'items': items.map(toJsonT).toList(),
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }

  factory PaginatedResultModel.fromEntity(PaginatedResult<T> paginatedResult) {
    return PaginatedResultModel(
      items: paginatedResult.items,
      currentPage: paginatedResult.currentPage,
      totalPages: paginatedResult.totalPages,
      totalItems: paginatedResult.totalItems,
      hasNextPage: paginatedResult.hasNextPage,
      hasPreviousPage: paginatedResult.hasPreviousPage,
    );
  }

  PaginatedResult<T> toEntity() {
    return PaginatedResult(
      items: items,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }
}
