class TitleFormatter {
  /// Shortens titles intelligently by preserving important information
  /// and removing common redundant phrases
  static String shortenTitle(String title, {int maxLength = 50}) {
    if (title.length <= maxLength) {
      return title;
    }

    // Common phrases to remove for shortening
    final redundantPhrases = [
      'Sunday Morning Worship Service',
      'Sunday Morning Service',
      'Morning Worship Service',
      'Worship Service',
      'Live Stream',
      'Live Worship',
      'Service',
      'Church Service',
      'Sunday Service',
      'Morning Service',
      'Evening Service',
      'Bible Study',
      'Prayer Meeting',
      '- Live',
      'Live -',
    ];

    String shortened = title;

    // Remove redundant phrases if title is too long
    for (final phrase in redundantPhrases) {
      if (shortened.length > maxLength) {
        // Try removing the phrase (case insensitive)
        shortened = shortened.replaceAll(
          RegExp(phrase, caseSensitive: false),
          '',
        );
        // Clean up extra spaces and dashes
        shortened = shortened
            .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces to single
            .replaceAll(RegExp(r'\s*-\s*'), ' - ') // Clean up dashes
            .replaceAll(RegExp(r'^[\s\-]+|[\s\-]+$'), '') // Trim spaces/dashes
            .trim();
      }
    }

    // If still too long, try to keep the most important part
    if (shortened.length > maxLength) {
      // Look for date patterns and keep them
      final dateMatch = RegExp(
        r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*\s+\d{1,2}(?:,?\s+\d{4})?\b',
      ).firstMatch(shortened);

      // Look for special occasions
      final occasionWords = [
        'Christmas',
        'Easter',
        'Thanksgiving',
        'New Year',
        'Palm Sunday',
        'Good Friday',
        'Pentecost',
        'Advent',
      ];
      String? occasion;
      for (final word in occasionWords) {
        if (shortened.toLowerCase().contains(word.toLowerCase())) {
          occasion = word;
          break;
        }
      }

      // Priority: Keep occasion + date if possible
      if (occasion != null && dateMatch != null) {
        final combined = '$occasion ${dateMatch.group(0)}';
        if (combined.length <= maxLength) {
          return combined;
        }
      }

      // Keep just the occasion
      if (occasion != null && occasion.length <= maxLength) {
        return occasion;
      }

      // Keep just the date
      if (dateMatch != null && dateMatch.group(0)!.length <= maxLength) {
        return dateMatch.group(0)!;
      }

      // Last resort: Simple truncation with ellipsis
      return '${shortened.substring(0, maxLength - 3)}...';
    }

    return shortened;
  }

  /// Provides different length variations for different UI contexts
  static String shortenForCard(String title) =>
      shortenTitle(title, maxLength: 35); // More aggressive for cards
  static String shortenForList(String title) =>
      shortenTitle(title, maxLength: 60);
  static String shortenForHeader(String title) =>
      shortenTitle(title, maxLength: 30); // More aggressive for headers

  /// Examples of how titles get shortened:
  ///
  /// "Sunday Morning Worship Service - Christmas Eve Celebration - December 24, 2024"
  /// → "Christmas Eve - December 24, 2024"
  ///
  /// "Live Stream: Morning Worship Service with Pastor John"
  /// → "with Pastor John"
  ///
  /// "Bible Study: Living with Purpose - Week 3 of 8"
  /// → "Living with Purpose - Week 3 of 8"
}
