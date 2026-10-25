
import '../../domain/entities/session_log.dart';

class SessionLogModel extends SessionLog {
  const SessionLogModel({
    super.id,
    required super.presetId,
    required super.date,
    required super.completedSeconds,
    required super.status,
    super.notes,
  });

  factory SessionLogModel.fromMap(Map<String, Object?> map) {
    return SessionLogModel(
      id: map['id'] as int?,
      presetId: map['preset_id'] as int,
      date: DateTime.parse(map['date'] as String),
      completedSeconds: map['completed_seconds'] as int,
      status: map['status'] as String,
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'preset_id': presetId,
      'date': date.toIso8601String(),
      'completed_seconds': completedSeconds,
      'status': status,
      'notes': notes,
    };
  }

  factory SessionLogModel.fromEntity(SessionLog session) {
    return SessionLogModel(
      id: session.id,
      presetId: session.presetId,
      date: session.date,
      completedSeconds: session.completedSeconds,
      status: session.status,
      notes: session.notes,
    );
  }
}
