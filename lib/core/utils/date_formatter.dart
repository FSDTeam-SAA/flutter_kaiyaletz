/// Formats [date] as "yyyy-MM-dd", e.g. "2026-08-14".
String formatDate(DateTime date) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Formats [date] as "August 22, 2026", in local time.
String formatLongDate(DateTime date) {
  final d = date.toLocal();
  return '${_months[d.month - 1]} ${d.day}, ${d.year}';
}
