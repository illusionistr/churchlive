import 'package:equatable/equatable.dart';

/// Country entity
class Country extends Equatable {
  final String id;
  final String name;
  final String code;
  final DateTime createdAt;

  const Country({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, code, createdAt];
}

/// Language entity
class Language extends Equatable {
  final String id;
  final String name;
  final String code;
  final DateTime createdAt;

  const Language({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, code, createdAt];
}

/// Denomination entity
class Denomination extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int clickCount;

  const Denomination({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.clickCount = 0,
  });

  @override
  List<Object?> get props => [id, name, description, createdAt, clickCount];
}

/// Paginated result wrapper
class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  @override
  List<Object?> get props => [
    items,
    currentPage,
    totalPages,
    totalItems,
    hasNextPage,
    hasPreviousPage,
  ];
}
