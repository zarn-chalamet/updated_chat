import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatMessageTimestamp(Timestamp timestamp) {
  DateTime messageDate = timestamp.toDate();
  DateTime now = DateTime.now();

  // Check if the message was sent today
  bool isToday = now.year == messageDate.year &&
      now.month == messageDate.month &&
      now.day == messageDate.day;

  if (isToday) {
    // If the message was sent today, show only the time
    return DateFormat.jm().format(messageDate); // 10:53 PM
  } else {
    // If the message was sent on a previous day, show date and time
    return DateFormat('MMM d \'AT\' h:mm a')
        .format(messageDate); // AUG 17 AT 8:13 AM
  }
}

bool shouldShowDateLabel(
    Timestamp currentTimestamp, Timestamp? previousTimestamp) {
  if (previousTimestamp == null) {
    return true; // Always show label for the first message
  }

  DateTime currentDate = currentTimestamp.toDate();
  DateTime previousDate = previousTimestamp.toDate();

  return currentDate.year != previousDate.year ||
      currentDate.month != previousDate.month ||
      currentDate.day != previousDate.day;
}

String formatTimestamp(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateTime startOfToday = DateTime(now.year, now.month, now.day);
  DateTime startOfWeek = startOfToday.subtract(Duration(days: now.weekday - 1));

  if (dateTime.isAfter(startOfToday)) {
    // Message is from today
    return DateFormat('hh:mm a').format(dateTime);
  } else if (dateTime.isAfter(startOfWeek)) {
    // Message is from this week
    return DateFormat('EEE').format(dateTime); // Mon, Tue, etc.
  } else {
    // Message is older than this week
    return DateFormat('MMM d').format(dateTime); // Aug 15, Jul 27, etc.
  }
}
