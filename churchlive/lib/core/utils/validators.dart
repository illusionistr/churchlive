class Validators {
  /// Validates required fields
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates optional email (empty is allowed)
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL (starting with http:// or https://)';
    }

    return null;
  }

  /// Validates optional URL (empty is allowed)
  static String? optionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
      r'^https?:\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL (starting with http:// or https://)';
    }

    return null;
  }

  /// Validates phone number
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates optional phone number
  static String? optionalPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int minLength) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    if (value.trim().length < minLength) {
      return 'Must be at least $minLength characters long';
    }

    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int maxLength) {
    if (value != null && value.length > maxLength) {
      return 'Must be no more than $maxLength characters long';
    }
    return null;
  }

  /// Validates that value matches another value (for password confirmation)
  static String? matchesValue(
    String? value,
    String? otherValue,
    String fieldName,
  ) {
    if (value != otherValue) {
      return 'Does not match $fieldName';
    }
    return null;
  }

  /// Validates YouTube URL specifically
  static String? youtubeUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final youtubeRegex = RegExp(
      r'^https?:\/\/(?:www\.)?youtube\.com\/(channel\/|c\/|user\/|@)[a-zA-Z0-9_-]+\/?$',
      caseSensitive: false,
    );

    if (!youtubeRegex.hasMatch(value.trim())) {
      return 'Please enter a valid YouTube channel URL';
    }

    return null;
  }
}
