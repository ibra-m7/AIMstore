import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/pickup_slots.dart';

class PickupApi {
  PickupApi._();
  static final PickupApi instance = PickupApi._();

  final _client = ApiClient.instance;

  Future<PickupSlotsCalendar> slots() async {
    final json = await _client.get('/pickup/slots', auth: true);
    final data = json['data'];
    if (data is! Map) {
      throw ApiException(
        (json['message'] as String?) ?? 'تعذّر تحميل فترات التجهيز.',
      );
    }
    return PickupSlotsCalendar.fromJson(Map<String, dynamic>.from(data));
  }
}
