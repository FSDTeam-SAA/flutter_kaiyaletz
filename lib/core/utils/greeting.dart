/// Returns a time-based greeting: "Good morning" before noon,
/// "Good afternoon" until 5pm, "Good evening" after that.
String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
