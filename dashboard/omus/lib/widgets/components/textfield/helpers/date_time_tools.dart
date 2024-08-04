import "package:flutter/material.dart";
import "package:intl/intl.dart";

abstract class DateTimeTools {
  static final defaultStartDateTime = DateTime(1900);
  static final defaultEndDateTime = DateTime(2100);

  static TimeOfDay? getTimeOfDayFromDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static DateTime? getDateTimeFromTimeOfDay(
    TimeOfDay? time, {
    DateTime? date,
  }) {
    if (time == null) {
      return null;
    }
    final now = date ?? DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  static String formatTodayDateTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inDays > 0) {
      return DateFormat("dd.MM.yyyy").format(dateTime);
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inSeconds >= 1) {
      return "A few seconds ago";
    } else {
      return "Just now";
    }
  }

  static String formatDDMMYYYY(DateTime? dateTime) => dateTime != null ? DateFormat("dd.MM.yyyy").format(dateTime) : "";

  static String formatHhMmDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return "NA";
    }
    return DateFormat("HH:mm").format(dateTime);
  }

  static String getRangeDateText(DateTimeRange? dateTimeRange, MaterialLocalizations localizations) {
    if (dateTimeRange == null) return "-";
    final firstDate = localizations.formatCompactDate(dateTimeRange.start);
    final lastDate = localizations.formatCompactDate(dateTimeRange.end);
    return "$firstDate - $lastDate";
  }
}
