/// Date formatting helpers for the meeting details screen.
class MeetingDateFormatter {
  MeetingDateFormatter._();

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  /// e.g. "Wednesday, August 5, 2026 at 7:10 PM"
  static String fullDate(DateTime d) {
    final wd = _weekdays[d.weekday - 1];
    final mo = _months[d.month - 1];
    final hr = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    return '$wd, $mo ${d.day}, ${d.year} at $hr:$min $amPm';
  }

  /// e.g. "12:20:03 AM"
  static String time(DateTime d) {
    final hr = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
    final sec = d.second.toString().padLeft(2, '0');
    return '$hr:$min:$sec $amPm';
  }
}
