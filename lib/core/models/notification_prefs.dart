class NotificationPrefs {
  const NotificationPrefs({
    this.pushType1 = true,
    this.pushType2 = false,
    this.pushType3 = false,
    this.emailOnMatch = false,
  });

  final bool pushType1;
  final bool pushType2;
  final bool pushType3;
  final bool emailOnMatch;

  factory NotificationPrefs.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationPrefs();
    return NotificationPrefs(
      pushType1: map['pushType1'] as bool? ?? true,
      pushType2: map['pushType2'] as bool? ?? false,
      pushType3: map['pushType3'] as bool? ?? false,
      emailOnMatch: map['emailOnMatch'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'pushType1': pushType1,
        'pushType2': pushType2,
        'pushType3': pushType3,
        'emailOnMatch': emailOnMatch,
      };

  NotificationPrefs copyWith({
    bool? pushType1,
    bool? pushType2,
    bool? pushType3,
    bool? emailOnMatch,
  }) {
    return NotificationPrefs(
      pushType1: pushType1 ?? this.pushType1,
      pushType2: pushType2 ?? this.pushType2,
      pushType3: pushType3 ?? this.pushType3,
      emailOnMatch: emailOnMatch ?? this.emailOnMatch,
    );
  }
}
