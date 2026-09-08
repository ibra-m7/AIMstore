class PickupSlot {
  final String id;
  final int hour;
  final int minute;
  final int hour24;
  final String period;
  final String periodLetter;
  final String timeLabel;
  final String start;
  final bool available;
  final DateTime startsAt;

  const PickupSlot({
    required this.id,
    required this.hour,
    required this.minute,
    required this.hour24,
    required this.period,
    required this.periodLetter,
    required this.timeLabel,
    required this.start,
    required this.available,
    required this.startsAt,
  });

  factory PickupSlot.fromJson(Map<String, dynamic> json) {
    return PickupSlot(
      id: (json['id'] as String?) ?? '',
      hour: (json['hour'] as num?)?.toInt() ?? 0,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
      hour24: (json['hour_24'] as num?)?.toInt() ?? 0,
      period: (json['period'] as String?) ?? 'morning',
      periodLetter: (json['period_letter'] as String?) ?? 'ص',
      timeLabel: (json['time_label'] as String?) ?? '',
      start: (json['start'] as String?) ?? '',
      available: json['available'] as bool? ?? true,
      startsAt: DateTime.tryParse((json['starts_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class PickupDay {
  final String date;
  final String label;
  final int weekday;
  final String weekdayLabel;
  final List<PickupSlot> slots;

  const PickupDay({
    required this.date,
    required this.label,
    required this.weekday,
    required this.weekdayLabel,
    this.slots = const [],
  });

  factory PickupDay.fromJson(Map<String, dynamic> json) {
    final slots = <PickupSlot>[];
    final raw = json['slots'];
    if (raw is List) {
      for (final item in raw.whereType<Map>()) {
        slots.add(PickupSlot.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return PickupDay(
      date: (json['date'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      weekday: (json['weekday'] as num?)?.toInt() ?? 0,
      weekdayLabel: (json['weekday_label'] as String?) ?? '',
      slots: slots,
    );
  }
}

class PickupSlotsCalendar {
  final bool nowAvailable;
  final String nowLabel;
  final List<PickupDay> days;

  const PickupSlotsCalendar({
    this.nowAvailable = true,
    this.nowLabel = 'الآن',
    this.days = const [],
  });

  factory PickupSlotsCalendar.fromJson(Map<String, dynamic> json) {
    final days = <PickupDay>[];
    final raw = json['days'];
    if (raw is List) {
      for (final item in raw.whereType<Map>()) {
        days.add(PickupDay.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return PickupSlotsCalendar(
      nowAvailable: json['now_available'] as bool? ?? true,
      nowLabel: (json['now_label'] as String?) ?? 'الآن',
      days: days,
    );
  }
}

class PickupSlotSelection {
  final bool fulfillNow;
  final PickupDay? day;
  final PickupSlot? slot;

  const PickupSlotSelection.now()
      : fulfillNow = true,
        day = null,
        slot = null;

  const PickupSlotSelection.scheduled({
    required this.day,
    required this.slot,
  }) : fulfillNow = false;

  DateTime? get scheduledAt => slot?.startsAt;
}
