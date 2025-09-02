import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import 'package:storage_client/storage_client.dart' as storage_client;
import 'exceptions.dart';
import 'failures.dart';
import '../constants/app_constants.dart';

class ErrorMapper {
  static AppException mapToException(dynamic error) {
    if (error is AuthException) {
      return AuthenticationException(
        message: error.message,
        code: _parseStatusCode(error.statusCode),
        originalException: error,
      );
    }

    if (error is PostgrestException) {
      return DatabaseException(
        message: error.message,
        code: _parseStatusCode(error.code),
        originalException: error,
      );
    }

    if (error is storage_client.StorageException) {
      return StorageException(
        message: error.message,
        code: _parseStatusCode(error.statusCode),
        originalException: error,
      );
    }

    // Handle common HTTP status codes
    if (error.toString().contains('timeout') ||
        error.toString().contains('TimeoutException')) {
      return const TimeoutException(
        message: AppConstants.errorTimeout,
        code: 408,
      );
    }

    if (error.toString().contains('network') ||
        error.toString().contains('connection') ||
        error.toString().contains('SocketException')) {
      return const NetworkException(
        message: AppConstants.errorNoInternet,
        code: 0,
      );
    }

    // Default to AppException
    return AppException(
      message: error.toString().isNotEmpty
          ? error.toString()
          : AppConstants.errorUnknown,
      originalException: error,
    );
  }

  static Failure mapToFailure(dynamic error) {
    final exception = error is AppException ? error : mapToException(error);

    switch (exception.runtimeType) {
      case AuthenticationException:
        return AuthenticationFailure(
          message: exception.message,
          code: exception.code,
        );

      case UnauthorizedException:
        return UnauthorizedFailure(
          message: exception.message,
          code: exception.code,
        );

      case DatabaseException:
        return DatabaseFailure(
          message: exception.message,
          code: exception.code,
        );

      case NotFoundException:
        return NotFoundFailure(
          message: exception.message,
          code: exception.code,
        );

      case NetworkException:
        return NetworkFailure(message: exception.message, code: exception.code);

      case TimeoutException:
        return TimeoutFailure(message: exception.message, code: exception.code);

      case ValidationException:
        final validationException = exception as ValidationException;
        return ValidationFailure(
          message: exception.message,
          code: exception.code,
          errors: validationException.errors,
        );

      case CacheException:
        return CacheFailure(message: exception.message, code: exception.code);

      case StorageException:
        return StorageFailure(message: exception.message, code: exception.code);

      case PermissionException:
        return PermissionFailure(
          message: exception.message,
          code: exception.code,
        );

      default:
        return UnknownFailure(message: exception.message, code: exception.code);
    }
  }

  static int? _parseStatusCode(dynamic code) {
    if (code is int) return code;
    if (code is String) return int.tryParse(code);
    return null;
  }

  static String getUserFriendlyMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Please check your internet connection and try again.';

      case TimeoutFailure:
        return 'The request took too long. Please try again.';

      case AuthenticationFailure:
        return 'Authentication failed. Please check your credentials.';

      case UnauthorizedFailure:
        return 'You are not authorized to perform this action.';

      case NotFoundFailure:
        return 'The requested resource was not found.';

      case ValidationFailure:
        final validationFailure = failure as ValidationFailure;
        if (validationFailure.errors?.isNotEmpty == true) {
          return validationFailure.errors!.values.first;
        }
        return 'Please check your input and try again.';

      case StorageFailure:
        return 'Failed to upload or download file. Please try again.';

      case PermissionFailure:
        return 'Permission denied. Please check your permissions.';

      default:
        return failure.message.isNotEmpty
            ? failure.message
            : 'Something went wrong. Please try again.';
    }
  }
}
