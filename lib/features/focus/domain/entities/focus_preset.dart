
class FocusPreset {
  final int? id;
  final String name;
  final String moodTag;
  final int durationMinutes;

  const FocusPreset({
    this.id,
    required this.name,
    required this.moodTag,
    required this.durationMinutes,
  });

  FocusPreset copyWith({
    int? id,
    String? name,
    String? moodTag,
    int? durationMinutes,
  }) {
    return FocusPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      moodTag: moodTag ?? this.moodTag,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
