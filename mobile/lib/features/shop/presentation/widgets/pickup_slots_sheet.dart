import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/pickup_slots.dart';
import '../../data/services/pickup_api.dart';
import 'checkout_sheet.dart';

class PickupSlotsSheet {
  static Future<PickupSlotSelection?> show(
    BuildContext context, {
    PickupSlotSelection? initial,
  }) {
    return showCheckoutSheet<PickupSlotSelection>(
      context: context,
      builder: (_) => _PickupSlotsBody(initial: initial),
    );
  }
}

class _PickupSlotsBody extends StatefulWidget {
  final PickupSlotSelection? initial;
  const _PickupSlotsBody({this.initial});

  @override
  State<_PickupSlotsBody> createState() => _PickupSlotsBodyState();
}

class _PickupSlotsBodyState extends State<_PickupSlotsBody> {
  static const double _itemExtent = 48;
  static const double _wheelHeight = 220;

  PickupSlotsCalendar? _calendar;
  String? _error;
  bool _loading = true;
  int _dayIndex = 0;
  int _slotIndex = 0;

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _slotController;

  @override
  void initState() {
    super.initState();
    _dayController = FixedExtentScrollController();
    _slotController = FixedExtentScrollController();
    _load();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _slotController.dispose();
    super.dispose();
  }

  List<PickupDay> get _days => _calendar?.days ?? const [];

  List<PickupSlot> _slotsForDay(int dayIndex) {
    final days = _days;
    if (days.isEmpty) return const [];
    final day = days[dayIndex.clamp(0, days.length - 1)];
    final slots = [...day.slots]..sort((a, b) => a.start.compareTo(b.start));
    final available = slots.where((s) => s.available).toList();
    return available.isNotEmpty ? available : slots;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final calendar = await PickupApi.instance.slots();
      if (!mounted) return;

      var dayIndex = 0;
      var slotIndex = 0;
      final days = calendar.days;

      if (widget.initial?.day != null) {
        final i = days.indexWhere((d) => d.date == widget.initial!.day!.date);
        if (i >= 0) dayIndex = i;
      }

      if (days.isNotEmpty) {
        final day = days[dayIndex.clamp(0, days.length - 1)];
        final slots = [...day.slots]..sort((a, b) => a.start.compareTo(b.start));
        final available = slots.where((s) => s.available).toList();
        final list = available.isNotEmpty ? available : slots;
        if (widget.initial?.slot != null) {
          final si = list.indexWhere((s) => s.id == widget.initial!.slot!.id);
          if (si >= 0) slotIndex = si;
        }
      }

      final oldDay = _dayController;
      final oldSlot = _slotController;
      _dayController = FixedExtentScrollController(initialItem: dayIndex);
      _slotController = FixedExtentScrollController(initialItem: slotIndex);

      setState(() {
        _calendar = calendar;
        _dayIndex = dayIndex;
        _slotIndex = slotIndex;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldDay.dispose();
        oldSlot.dispose();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذّر تحميل فترات التجهيز.';
      });
    }
  }

  void _onDayChanged(int index) {
    if (index == _dayIndex) return;
    final oldSlot = _slotController;
    _slotController = FixedExtentScrollController(initialItem: 0);
    setState(() {
      _dayIndex = index;
      _slotIndex = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => oldSlot.dispose());
  }

  void _onSlotChanged(int index) {
    if (index == _slotIndex) return;
    setState(() => _slotIndex = index);
  }

  void _continue() {
    final days = _days;
    if (days.isEmpty) return;
    final day = days[_dayIndex.clamp(0, days.length - 1)];
    final slots = _slotsForDay(_dayIndex);
    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اختر فترة تجهيز متاحة', textAlign: TextAlign.center),
        ),
      );
      return;
    }
    final slot = slots[_slotIndex.clamp(0, slots.length - 1)];
    if (!slot.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذه الفترة غير متاحة', textAlign: TextAlign.center),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      PickupSlotSelection.scheduled(day: day, slot: slot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    final slots = _slotsForDay(_dayIndex);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.58,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(22, 18, 22, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: AppTheme.primaryDark,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'فترة التجهيز',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.darkText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'مرّر لاختيار وقت التجهيز المناسب',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: 14,
                    left: 16,
                    child: CheckoutSheetCloseButton(),
                  ),
                ],
              ),
              Flexible(
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryDark,
                              strokeWidth: 2.6,
                            ),
                          ),
                        ),
                      )
                    : _error != null
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFC62828),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _load,
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          )
                        : days.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 36),
                                child: Text(
                                  'لا توجد فترات متاحة حالياً',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.mutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 4, 12, 8),
                                child: SizedBox(
                                  height: _wheelHeight,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      IgnorePointer(
                                        child: Container(
                                          height: _itemExtent,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F4F2),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: const Color(0xFFE0E8E3),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: ListWheelScrollView.useDelegate(
                                              controller: _dayController,
                                              itemExtent: _itemExtent,
                                              physics:
                                                  const FixedExtentScrollPhysics(),
                                              perspective: 0.003,
                                              diameterRatio: 1.35,
                                              overAndUnderCenterOpacity: 0.35,
                                              onSelectedItemChanged:
                                                  _onDayChanged,
                                              childDelegate:
                                                  ListWheelChildBuilderDelegate(
                                                childCount: days.length,
                                                builder: (context, index) {
                                                  final selected =
                                                      index == _dayIndex;
                                                  return Center(
                                                    child: Text(
                                                      days[index].label,
                                                      style: TextStyle(
                                                        fontWeight: selected
                                                            ? FontWeight.w900
                                                            : FontWeight.w600,
                                                        fontSize:
                                                            selected ? 16 : 14,
                                                        color: selected
                                                            ? AppTheme.darkText
                                                            : AppTheme
                                                                .mutedText,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: slots.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                      'لا توجد فترات',
                                                      style: TextStyle(
                                                        color:
                                                            AppTheme.mutedText,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  )
                                                : ListWheelScrollView.useDelegate(
                                                    key: ValueKey(
                                                      'pickup-slot-day-$_dayIndex',
                                                    ),
                                                    controller: _slotController,
                                                    itemExtent: _itemExtent,
                                                    physics:
                                                        const FixedExtentScrollPhysics(),
                                                    perspective: 0.003,
                                                    diameterRatio: 1.35,
                                                    overAndUnderCenterOpacity:
                                                        0.35,
                                                    onSelectedItemChanged:
                                                        _onSlotChanged,
                                                    childDelegate:
                                                        ListWheelChildBuilderDelegate(
                                                      childCount: slots.length,
                                                      builder:
                                                          (context, index) {
                                                        final slot =
                                                            slots[index];
                                                        final selected =
                                                            index ==
                                                                _slotIndex;
                                                        final fg = !slot
                                                                .available
                                                            ? AppTheme
                                                                .mutedText
                                                            : selected
                                                                ? AppTheme
                                                                    .darkText
                                                                : AppTheme
                                                                    .mutedText;
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  slot.timeLabel,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        selected
                                                                            ? FontWeight.w900
                                                                            : FontWeight.w600,
                                                                    fontSize:
                                                                        selected
                                                                            ? 15.5
                                                                            : 13.5,
                                                                    color: fg,
                                                                    decoration: slot.available
                                                                        ? null
                                                                        : TextDecoration
                                                                            .lineThrough,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading || days.isEmpty || slots.isEmpty
                        ? null
                        : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFB7C9BC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'الاستمرار',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 22,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
