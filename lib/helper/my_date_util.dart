import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyDateUtil {
  // Returns formatted time for messages, e.g., "5:45 PM"
  static String getFormattedTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat.jm().format(dateTime);
  }

  // Returns formatted date, e.g., "May 12"
  static String getFormattedDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d').format(dateTime);
  }

  // Returns full formatted date and time, e.g., "May 12, 5:45 PM"
  static String getFullFormattedDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  // Returns 'Today', 'Yesterday', or a date depending on timestamp
  static String getLastMessageTime(Timestamp timestamp) {
    DateTime messageDate = timestamp.toDate();
    DateTime now = DateTime.now();

    if (messageDate.day == now.day &&
        messageDate.month == now.month &&
        messageDate.year == now.year) {
      return DateFormat.jm().format(messageDate); // e.g., 4:30 PM
    } else if (messageDate.day == now.subtract(const Duration(days: 1)).day &&
        messageDate.month == now.month &&
        messageDate.year == now.year) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yy').format(messageDate);
    }
  }

  // Returns true if two timestamps are more than a minute apart
  static bool isNewMessageGap(Timestamp a, Timestamp b) {
    return a.toDate().difference(b.toDate()).inMinutes > 1;
  }
}
