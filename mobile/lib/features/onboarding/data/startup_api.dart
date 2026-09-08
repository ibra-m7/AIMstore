import '../../../../core/network/api_client.dart';
import '../../../../core/utils/gcc_phone.dart';

class SplashConfig {
  final String mediaType;
  final String mediaUrl;
  final int durationMs;
  final String? title;

  const SplashConfig({
    required this.mediaType,
    required this.mediaUrl,
    required this.durationMs,
    this.title,
  });

  bool get isVideo => mediaType == 'video';
  bool get hasMedia => mediaUrl.trim().isNotEmpty;

  factory SplashConfig.fromJson(Map<String, dynamic> json) {
    return SplashConfig(
      mediaType: (json['media_type'] as String?) ?? 'image',
      mediaUrl: (json['media_url'] as String?) ?? '',
      durationMs: (json['duration_ms'] as num?)?.toInt() ?? 2500,
      title: json['title'] as String?,
    );
  }
}

class OnboardingSlideData {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final int sortOrder;

  const OnboardingSlideData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory OnboardingSlideData.fromJson(Map<String, dynamic> json) {
    return OnboardingSlideData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      imageUrl: (json['image_url'] as String?) ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class StartupPhoneConfig {
  final String defaultCountryCode;
  final List<GccPhoneCountry> countries;

  const StartupPhoneConfig({
    required this.defaultCountryCode,
    required this.countries,
  });

  factory StartupPhoneConfig.fromJson(Map<String, dynamic> json) {
    final countries = <GccPhoneCountry>[];
    final raw = json['countries'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final country = GccPhoneCountry.fromApi(
            Map<String, dynamic>.from(item),
          );
          if (country.code.isNotEmpty) {
            countries.add(country);
          }
        }
      }
    }

    return StartupPhoneConfig(
      defaultCountryCode: (json['default_country_code'] as String?) ?? '',
      countries: countries,
    );
  }
}

class StartupPayload {
  final SplashConfig? splash;
  final List<OnboardingSlideData> onboarding;
  final StartupPhoneConfig? phone;

  const StartupPayload({
    this.splash,
    this.onboarding = const [],
    this.phone,
  });

  factory StartupPayload.fromJson(Map<String, dynamic> json) {
    final splashRaw = json['splash'];
    SplashConfig? splash;
    if (splashRaw is Map) {
      final parsed = SplashConfig.fromJson(Map<String, dynamic>.from(splashRaw));
      if (parsed.hasMedia) splash = parsed;
    }

    final slides = <OnboardingSlideData>[];
    final raw = json['onboarding'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          slides.add(
            OnboardingSlideData.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    StartupPhoneConfig? phone;
    final phoneRaw = json['phone'];
    if (phoneRaw is Map) {
      phone = StartupPhoneConfig.fromJson(
        Map<String, dynamic>.from(phoneRaw),
      );
    }

    return StartupPayload(
      splash: splash,
      onboarding: slides,
      phone: phone,
    );
  }
}

class StartupApi {
  StartupApi._();
  static final StartupApi instance = StartupApi._();

  StartupPayload? _cache;

  StartupPayload? get cached => _cache;

  Future<StartupPayload> fetch({bool force = false}) async {
    if (!force && _cache != null) return _cache!;
    try {
      final json = await ApiClient.instance.get(
        '/startup',
        auth: false,
        timeout: const Duration(seconds: 4),
      );
      final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final payload = StartupPayload.fromJson(data);
      _cache = payload;
      final phone = payload.phone;
      if (phone != null && phone.countries.isNotEmpty) {
        GccPhone.applyStartup(
          defaultCountryCode: phone.defaultCountryCode,
          countries: phone.countries,
        );
      }
    } catch (_) {
      _cache ??= const StartupPayload();
    }
    return _cache!;
  }
}
