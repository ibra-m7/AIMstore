class DeliverySlot {
  final String id;
  final String start;
  final String end;
  final String label;
  final String period;
  final bool available;
  final DateTime startsAt;

  const DeliverySlot({
    required this.id,
    required this.start,
    required this.end,
    required this.label,
    this.period = 'morning',
    required this.available,
    required this.startsAt,
  });

  bool get isMorning => period == 'morning';

  String get periodLetter => isMorning ? 'ص' : 'م';

  /// نطاق الوقت بدون ص/م — للعرض في صفوف القائمة.
  String get timeRange {
    final fromLabel = label.replaceAll(RegExp(r'\s*[صم]\s*$'), '').trim();
    if (fromLabel.contains('-')) return fromLabel;
    return '${_clock12(start)} - ${_clock12(end)}';
  }

  static String _clock12(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.firstOrNull ?? '') ?? 0;
    final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m';
  }

  factory DeliverySlot.fromJson(Map<String, dynamic> json) {
    final start = (json['start'] as String?) ?? '';
    final periodRaw = (json['period'] as String?) ?? '';
    final period = periodRaw == 'evening' || periodRaw == 'morning'
        ? periodRaw
        : _periodFromStart(start);

    return DeliverySlot(
      id: (json['id'] as String?) ?? '',
      start: start,
      end: (json['end'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      period: period,
      available: json['available'] as bool? ?? true,
      startsAt: DateTime.tryParse((json['starts_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  static String _periodFromStart(String start) {
    final hour = int.tryParse(start.split(':').firstOrNull ?? '') ?? 0;
    return hour < 12 ? 'morning' : 'evening';
  }
}

class DeliveryDay {
  final String date;
  final String label;
  final int weekday;
  final String weekdayLabel;
  final List<DeliverySlot> slots;

  const DeliveryDay({
    required this.date,
    required this.label,
    required this.weekday,
    required this.weekdayLabel,
    this.slots = const [],
  });

  factory DeliveryDay.fromJson(Map<String, dynamic> json) {
    final slots = <DeliverySlot>[];
    final raw = json['slots'];
    if (raw is List) {
      for (final item in raw.whereType<Map>()) {
        slots.add(DeliverySlot.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return DeliveryDay(
      date: (json['date'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      weekday: (json['weekday'] as num?)?.toInt() ?? 0,
      weekdayLabel: (json['weekday_label'] as String?) ?? '',
      slots: slots,
    );
  }
}

class DeliverySlotsCalendar {
  final bool nowAvailable;
  final String nowLabel;
  final List<DeliveryDay> days;

  const DeliverySlotsCalendar({
    this.nowAvailable = true,
    this.nowLabel = 'الآن',
    this.days = const [],
  });

  factory DeliverySlotsCalendar.fromJson(Map<String, dynamic> json) {
    final days = <DeliveryDay>[];
    final raw = json['days'];
    if (raw is List) {
      for (final item in raw.whereType<Map>()) {
        days.add(DeliveryDay.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return DeliverySlotsCalendar(
      nowAvailable: json['now_available'] as bool? ?? true,
      nowLabel: (json['now_label'] as String?) ?? 'الآن',
      days: days,
    );
  }
}

class DeliverySlotSelection {
  final bool fulfillNow;
  final DeliveryDay? day;
  final DeliverySlot? slot;

  const DeliverySlotSelection.now()
      : fulfillNow = true,
        day = null,
        slot = null;

  const DeliverySlotSelection.scheduled({
    required this.day,
    required this.slot,
  }) : fulfillNow = false;

  DateTime? get scheduledAt => slot?.startsAt;
}
