class AppointmentSelection {
  final String period; // Morning | Evening
  final String time;   // e.g., 10:30 AM
  final String type;   // voice | message | video

  const AppointmentSelection({
    required this.period,
    required this.time,
    required this.type,
  });
}
