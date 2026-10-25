
class SessionLog {
  final int? id;
  final int presetId;
  final DateTime date;
  final int completedSeconds;
  final String status;
  final String notes;

  const SessionLog({
    this.id,
    required this.presetId,
    required this.date,
    required this.completedSeconds,
    required this.status,
    this.notes = '',
  });

  SessionLog copyWith({
    int? id,
    int? presetId,
    DateTime? date,
    int? completedSeconds,
    String? status,
    String? notes,
  }) {
    return SessionLog(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      date: date ?? this.date,
      completedSeconds:
          completedSeconds ?? this.completedSeconds,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  double get completedMinutes => completedSeconds / 60.0;
}
