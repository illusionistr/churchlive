import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, super.code});
}

// Authentication Failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message, super.code});
}

// Database Failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

// Validation Failures
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({required super.message, super.code, this.errors});

  @override
  List<Object?> get props => [message, code, errors];
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

// Unknown Failures
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}

// Storage Failures
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

// Permission Failures
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});
}
