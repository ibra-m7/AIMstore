import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class DeviceFix {
  final double latitude;
  final double longitude;
  final String? city;
  final String? district;
  final String? street;
  final String? details;

  const DeviceFix({
    required this.latitude,
    required this.longitude,
    this.city,
    this.district,
    this.street,
    this.details,
  });

  String get preview {
    final parts = [
      if (street != null && street!.isNotEmpty) street,
      if (district != null && district!.isNotEmpty) district,
      if (city != null && city!.isNotEmpty) city,
    ];
    return parts.join('، ');
  }
}

class PlaceSuggestion {
  final String title;
  final String subtitle;
  final double latitude;
  final double longitude;

  const PlaceSuggestion({
    required this.title,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });
}

class DeviceLocation {
  DeviceLocation._();

  static const riyadh = DeviceFix(
    latitude: 24.7136,
    longitude: 46.6753,
    city: 'الرياض',
  );

  static Future<DeviceFix> current() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      // لا نفتح الإعدادات تلقائياً أثناء عرض الخريطة — يسبب انهيار على بعض الأجهزة.
      throw const DeviceLocationException(
        'خدمة الموقع مغلقة. فعّلها من إعدادات الجهاز ثم أعد المحاولة.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const DeviceLocationException(
        'نحتاج إذن الموقع لتحديد عنوان التوصيل.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const DeviceLocationException(
        'إذن الموقع مرفوض. فعّله من إعدادات التطبيق.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    return reverse(position.latitude, position.longitude);
  }

  static Future<DeviceFix?> search(String query) async {
    final suggestions = await suggest(query, limit: 1);
    if (suggestions.isEmpty) return null;
    final first = suggestions.first;
    return reverse(first.latitude, first.longitude);
  }

  static Future<List<PlaceSuggestion>> suggest(
    String query, {
    int limit = 6,
  }) async {
    final q = query.trim();
    if (q.length < 2) return const [];

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': q,
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '$limit',
        'accept-language': 'ar',
        'countrycodes': 'sa',
      });
      final response = await http.get(
        uri,
        headers: const {
          'User-Agent': 'RaoahAlkhamsa/1.0 (delivery-address)',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        return _suggestViaGeocoding(q, limit: limit);
      }
      final raw = jsonDecode(response.body);
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((item) {
            final lat = double.tryParse('${item['lat']}') ?? 0;
            final lng = double.tryParse('${item['lon']}') ?? 0;
            final display = '${item['display_name'] ?? ''}'.trim();
            final name = '${item['name'] ?? ''}'.trim();
            final title = name.isNotEmpty
                ? name
                : display.split(',').first.trim();
            final subtitle = display
                .replaceFirst(title, '')
                .replaceFirst(RegExp(r'^[\s,]+'), '')
                .trim();
            return PlaceSuggestion(
              title: title.isEmpty ? display : title,
              subtitle: subtitle,
              latitude: lat,
              longitude: lng,
            );
          })
          .where((s) => s.title.isNotEmpty && s.latitude != 0)
          .toList();
    } catch (_) {
      return _suggestViaGeocoding(q, limit: limit);
    }
  }

  static Future<List<PlaceSuggestion>> _suggestViaGeocoding(
    String query, {
    int limit = 6,
  }) async {
    try {
      final marks = await locationFromAddress(query);
      if (marks.isEmpty) return const [];
      final out = <PlaceSuggestion>[];
      for (final mark in marks.take(limit)) {
        final fix = await reverse(mark.latitude, mark.longitude);
        out.add(
          PlaceSuggestion(
            title: fix.street?.isNotEmpty == true
                ? fix.street!
                : (fix.district ?? fix.city ?? query),
            subtitle: [
              if (fix.district != null && fix.district != fix.street)
                fix.district,
              if (fix.city != null) fix.city,
            ].whereType<String>().join('، '),
            latitude: fix.latitude,
            longitude: fix.longitude,
          ),
        );
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  static Future<DeviceFix> reverse(double latitude, double longitude) async {
    String? city;
    String? district;
    String? street;
    try {
      final marks = await placemarkFromCoordinates(latitude, longitude);
      if (marks.isNotEmpty) {
        final place = marks.first;
        city = _firstNonEmpty([
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ]);
        district = _firstNonEmpty([
          place.subLocality,
          place.subAdministrativeArea,
        ]);
        street = _firstNonEmpty([place.street, place.thoroughfare]);
      }
    } catch (_) {
      city = 'السعودية';
    }

    return DeviceFix(
      latitude: latitude,
      longitude: longitude,
      city: city ?? 'السعودية',
      district: district,
      street: street,
      details: _firstNonEmpty([street, district, city]),
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}

class DeviceLocationException implements Exception {
  final String message;
  const DeviceLocationException(this.message);

  @override
  String toString() => message;
}
