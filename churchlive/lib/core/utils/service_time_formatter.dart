import '../../domain/entities/service_time.dart';
import 'package:intl/intl.dart';

class ServiceTimeFormatter {
  /// Formats a service time for display
  static String formatServiceTime(ServiceTime serviceTime) {
    try {
      // Parse the time string (assuming format like "09:00", "14:30", etc.)
      final timeParts = serviceTime.time.split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        final now = DateTime.now();
        final dateTime = DateTime(now.year, now.month, now.day, hour, minute);

        // Format to display time (e.g., "9:00 AM")
        return DateFormat.jm().format(dateTime);
      }
    } catch (e) {
      // If parsing fails, return the original time
      return serviceTime.time;
    }

    return serviceTime.time;
  }

  /// Groups service times by day and sorts them
  static Map<String, List<ServiceTime>> groupAndSortServiceTimes(
    List<ServiceTime> serviceTimes,
  ) {
    final grouped = <String, List<ServiceTime>>{};

    for (final serviceTime in serviceTimes) {
      if (!serviceTime.isActive) continue;

      final day = serviceTime.dayOfWeek.toLowerCase();
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(serviceTime);
    }

    // Sort times within each day
    for (final dayTimes in grouped.values) {
      dayTimes.sort((a, b) => _compareTime(a.time, b.time));
    }

    // Sort days by week order
    final sortedDays = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    final sortedGrouped = <String, List<ServiceTime>>{};

    for (final day in sortedDays) {
      if (grouped.containsKey(day)) {
        sortedGrouped[day] = grouped[day]!;
      }
    }

    return sortedGrouped;
  }

  /// Compares two time strings (format: "HH:mm")
  static int _compareTime(String time1, String time2) {
    try {
      final time1Parts = time1.split(':');
      final time2Parts = time2.split(':');

      if (time1Parts.length >= 2 && time2Parts.length >= 2) {
        final hour1 = int.parse(time1Parts[0]);
        final minute1 = int.parse(time1Parts[1]);
        final hour2 = int.parse(time2Parts[0]);
        final minute2 = int.parse(time2Parts[1]);

        final totalMinutes1 = hour1 * 60 + minute1;
        final totalMinutes2 = hour2 * 60 + minute2;

        return totalMinutes1.compareTo(totalMinutes2);
      }
    } catch (e) {
      // If parsing fails, do string comparison
      return time1.compareTo(time2);
    }

    return time1.compareTo(time2);
  }

  /// Gets the next upcoming service time
  static ServiceTime? getNextServiceTime(List<ServiceTime> serviceTimes) {
    if (serviceTimes.isEmpty) return null;

    final now = DateTime.now();
    final currentDay = _getDayOfWeekString(now.weekday);
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final activeTimes = serviceTimes.where((st) => st.isActive).toList();

    // First, look for services today that haven't started yet
    final todayTimes = activeTimes
        .where((st) => st.dayOfWeek.toLowerCase() == currentDay.toLowerCase())
        .where((st) => _compareTime(st.time, currentTime) > 0)
        .toList();

    if (todayTimes.isNotEmpty) {
      todayTimes.sort((a, b) => _compareTime(a.time, b.time));
      return todayTimes.first;
    }

    // If no services today, find the next service this week
    final daysOrder = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    final currentDayIndex = daysOrder.indexOf(currentDay.toLowerCase());

    for (int i = 1; i <= 7; i++) {
      final dayIndex = (currentDayIndex + i) % 7;
      final dayToCheck = daysOrder[dayIndex];

      final dayTimes = activeTimes
          .where((st) => st.dayOfWeek.toLowerCase() == dayToCheck)
          .toList();

      if (dayTimes.isNotEmpty) {
        dayTimes.sort((a, b) => _compareTime(a.time, b.time));
        return dayTimes.first;
      }
    }

    return null;
  }

  /// Converts weekday number to string
  static String _getDayOfWeekString(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'sunday';
    }
  }

  /// Formats service times for compact display
  static String formatCompactServiceTimes(List<ServiceTime> serviceTimes) {
    if (serviceTimes.isEmpty) return 'No service times available';

    final grouped = groupAndSortServiceTimes(serviceTimes);
    final entries = <String>[];

    for (final entry in grouped.entries) {
      final day = entry.key;
      final times = entry.value;

      if (times.length == 1) {
        entries.add(
          '${capitalizeFirst(day)} ${formatServiceTime(times.first)}',
        );
      } else {
        final timeStrings = times.map((t) => formatServiceTime(t)).join(', ');
        entries.add('${capitalizeFirst(day)} $timeStrings');
      }
    }

    return entries.join(' • ');
  }

  /// Capitalizes first letter of a string
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
