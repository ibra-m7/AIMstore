class GccPhoneCountry {
  const GccPhoneCountry({
    required this.code,
    required this.flag,
    required this.name,
    required this.dial,
    required this.placeholder,
    required this.pattern,
    this.maxLength = 10,
  });

  final String code;
  final String flag;
  final String name;
  final String dial;
  final String placeholder;
  final RegExp pattern;
  final int maxLength;

  String get compactLabel => '$flag $dial';

  bool isValid(String raw) => pattern.hasMatch(_digits(raw));

  String _digits(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  factory GccPhoneCountry.fromApi(Map<String, dynamic> json) {
    final code = (json['code'] as String?) ?? '';
    final fallback = GccPhone._fallbackByCode(code);
    final maxLength =
        (json['max_national_length'] as num?)?.toInt() ?? fallback.maxLength;
    return GccPhoneCountry(
      code: code.isNotEmpty ? code : fallback.code,
      flag: (json['flag'] as String?)?.trim().isNotEmpty == true
          ? (json['flag'] as String)
          : fallback.flag,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String)
          : fallback.name,
      dial: (json['dial'] as String?)?.trim().isNotEmpty == true
          ? (json['dial'] as String)
          : fallback.dial,
      placeholder: (json['placeholder'] as String?)?.trim().isNotEmpty == true
          ? (json['placeholder'] as String)
          : fallback.placeholder,
      pattern: fallback.pattern,
      maxLength: maxLength,
    );
  }
}

class GccPhone {
  GccPhone._();

  static String _defaultCode = '966';
  static List<GccPhoneCountry> _countries = List<GccPhoneCountry>.from(
    _fallbackCountries,
  );

  static String get defaultCode => _defaultCode;

  static List<GccPhoneCountry> get countries =>
      List<GccPhoneCountry>.unmodifiable(_countries);

  static final List<GccPhoneCountry> _fallbackCountries = [
    GccPhoneCountry(
      code: '966',
      flag: '🇸🇦',
      name: 'السعودية',
      dial: '+966',
      placeholder: '5XXXXXXXX',
      pattern: RegExp(r'^5\d{8}$'),
    ),
    GccPhoneCountry(
      code: '971',
      flag: '🇦🇪',
      name: 'الإمارات',
      dial: '+971',
      placeholder: '5XXXXXXXX',
      pattern: RegExp(r'^5\d{8}$'),
    ),
    GccPhoneCountry(
      code: '965',
      flag: '🇰🇼',
      name: 'الكويت',
      dial: '+965',
      placeholder: '5XXXXXXX',
      pattern: RegExp(r'^[569]\d{7}$'),
      maxLength: 8,
    ),
    GccPhoneCountry(
      code: '973',
      flag: '🇧🇭',
      name: 'البحرين',
      dial: '+973',
      placeholder: '3XXXXXXX',
      pattern: RegExp(r'^[36]\d{7}$'),
      maxLength: 8,
    ),
    GccPhoneCountry(
      code: '974',
      flag: '🇶🇦',
      name: 'قطر',
      dial: '+974',
      placeholder: '3XXXXXXX',
      pattern: RegExp(r'^[3567]\d{7}$'),
      maxLength: 8,
    ),
    GccPhoneCountry(
      code: '968',
      flag: '🇴🇲',
      name: 'عُمان',
      dial: '+968',
      placeholder: '7XXXXXXX',
      pattern: RegExp(r'^[79]\d{7}$'),
      maxLength: 8,
    ),
    GccPhoneCountry(
      code: '967',
      flag: '🇾🇪',
      name: 'اليمن',
      dial: '+967',
      placeholder: '7XXXXXXXX',
      pattern: RegExp(r'^7\d{8}$'),
    ),
  ];

  static GccPhoneCountry _fallbackByCode(String code) {
    return _fallbackCountries.firstWhere(
      (country) => country.code == code,
      orElse: () => _fallbackCountries.first,
    );
  }

  static void applyStartup({
    String? defaultCountryCode,
    List<GccPhoneCountry>? countries,
  }) {
    if (countries != null && countries.isNotEmpty) {
      _countries = List<GccPhoneCountry>.from(countries);
    }
    final preferred = (defaultCountryCode ?? '').trim();
    if (preferred.isNotEmpty &&
        _countries.any((country) => country.code == preferred)) {
      _defaultCode = preferred;
    } else {
      _defaultCode = _countries.first.code;
    }
  }

  static GccPhoneCountry countryByCode(String code) {
    return _countries.firstWhere(
      (country) => country.code == code,
      orElse: () => _countries.first,
    );
  }

  static String? combine(String countryCode, String national) {
    final country = countryByCode(countryCode);
    var digits = national.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (!country.isValid(digits)) {
      return null;
    }
    return '${country.code}$digits';
  }

  /// يفصل الرقم المحلي عن رمز دولة الخليج/اليمن للعرض.
  static String nationalDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    final sorted = [..._countries]
      ..sort((a, b) => b.code.length.compareTo(a.code.length));
    for (final country in sorted) {
      if (digits.startsWith(country.code) &&
          digits.length > country.code.length) {
        return digits.substring(country.code.length);
      }
    }
    return digits;
  }
}
