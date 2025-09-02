/// Utility class for formatting member count ranges
class MemberCountFormatter {
  /// Format member count range for display
  static String formatMemberCount(String? memberCountRange) {
    switch (memberCountRange) {
      case 'under_50':
        return 'Under 50 members';
      case '50_100':
        return '50-100 members';
      case '100_300':
        return '100-300 members';
      case '300_500':
        return '300-500 members';
      case '500_1000':
        return '500-1,000 members';
      case '1000_3000':
        return '1,000-3,000 members';
      case '3000_5000':
        return '3,000-5,000 members';
      case '5000_10000':
        return '5,000-10,000 members';
      case '10000_plus':
        return '10,000+ members';
      case 'unknown':
      case null:
      default:
        return 'Size not specified';
    }
  }

  /// Get short format for member count (for cards with limited space)
  static String formatMemberCountShort(String? memberCountRange) {
    switch (memberCountRange) {
      case 'under_50':
        return '<50';
      case '50_100':
        return '50-100';
      case '100_300':
        return '100-300';
      case '300_500':
        return '300-500';
      case '500_1000':
        return '500-1K';
      case '1000_3000':
        return '1K-3K';
      case '3000_5000':
        return '3K-5K';
      case '5000_10000':
        return '5K-10K';
      case '10000_plus':
        return '10K+';
      case 'unknown':
      case null:
      default:
        return 'Unknown';
    }
  }

  /// Get numeric value for sorting (returns the minimum value of the range)
  static int getSortValue(String? memberCountRange) {
    switch (memberCountRange) {
      case 'under_50':
        return 0;
      case '50_100':
        return 50;
      case '100_300':
        return 100;
      case '300_500':
        return 300;
      case '500_1000':
        return 500;
      case '1000_3000':
        return 1000;
      case '3000_5000':
        return 3000;
      case '5000_10000':
        return 5000;
      case '10000_plus':
        return 10000;
      case 'unknown':
      case null:
      default:
        return -1; // Sort unknowns to the end
    }
  }

  /// Get all available member count ranges for filtering
  static List<String> getAllRanges() {
    return [
      'under_50',
      '50_100',
      '100_300',
      '300_500',
      '500_1000',
      '1000_3000',
      '3000_5000',
      '5000_10000',
      '10000_plus',
    ];
  }

  /// Get display names for all ranges (for filter dropdowns)
  static Map<String, String> getRangeDisplayMap() {
    return {
      'under_50': 'Under 50',
      '50_100': '50-100',
      '100_300': '100-300',
      '300_500': '300-500',
      '500_1000': '500-1,000',
      '1000_3000': '1,000-3,000',
      '3000_5000': '3,000-5,000',
      '5000_10000': '5,000-10,000',
      '10000_plus': '10,000+',
    };
  }
}
