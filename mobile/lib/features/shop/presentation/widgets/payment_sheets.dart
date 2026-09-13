import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import 'checkout_sheet.dart';

class StcPaySheet {
  static Future<String?> show(
    BuildContext context, {
    String? initialPhone,
    String title = 'المحفظة الإلكترونية',
    String? assetPath,
    String? iconUrl,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showCheckoutSheet<String>(
      context: context,
      builder: (_) => _StcPayBody(
        initialPhone: initialPhone,
        title: title,
        assetPath: assetPath,
        iconUrl: iconUrl,
      ),
    );
  }
}

class _StcPayBody extends StatefulWidget {
  final String? initialPhone;
  final String title;
  final String? assetPath;
  final String? iconUrl;
  const _StcPayBody({
    this.initialPhone,
    required this.title,
    this.assetPath,
    this.iconUrl,
  });

  @override
  State<_StcPayBody> createState() => _StcPayBodyState();
}

class _StcPayBodyState extends State<_StcPayBody> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _normalized(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('967')) digits = digits.substring(3);
    if (digits.startsWith('966')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length == 9 &&
        (digits.startsWith('7') || digits.startsWith('5'))) {
      return '0$digits';
    }
    return null;
  }

  void _submit() {
    final phone = _normalized(_ctrl.text);
    if (phone == null) {
      setState(() => _error = 'أدخل رقم جوال يمني صحيح يبدأ بـ 07');
      return;
    }
    Navigator.of(context).pop(phone);
  }

  Widget _logo() {
    final url = (widget.iconUrl ?? '').trim();
    Widget child;
    if (url.startsWith('http')) {
      child = Image.network(
        url,
        width: 96,
        height: 56,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _assetLogo(),
      );
    } else {
      child = _assetLogo();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: child,
    );
  }

  Widget _assetLogo() {
    final asset = widget.assetPath;
    if (asset == null || asset.isEmpty) {
      return const Icon(
        Icons.account_balance_wallet_rounded,
        size: 40,
        color: AppTheme.primary,
      );
    }
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(asset, width: 96, height: 56);
    }
    return Image.asset(
      asset,
      width: 96,
      height: 56,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    const lightTitle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppTheme.darkText,
      height: 1.25,
    );
    const lightSubtitle = TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w400,
      color: AppTheme.mutedText,
      height: 1.35,
    );

    return CheckoutSheetFrame(
      title: widget.title,
      subtitle: 'أدخل رقم الجوال المرتبط بمحفظتك',
      titleStyle: lightTitle,
      subtitleStyle: lightSubtitle,
      footer: CheckoutSheetButton(
        label: 'تحقق من الرقم',
        background: AppTheme.primary,
        height: 46,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15.5,
          letterSpacing: 0.1,
        ),
        onPressed: _submit,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 2, 22, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: _logo()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              autofocus: false,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: AppTheme.darkText,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                hintText: '7xxxxxxxx',
                hintTextDirection: TextDirection.ltr,
                isDense: true,
                filled: true,
                fillColor: AppTheme.background,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.mutedText,
                ),
                floatingLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.mutedText.withValues(alpha: 0.7),
                ),
                prefixIcon: const Icon(
                  Icons.phone_iphone_rounded,
                  size: 20,
                  color: AppTheme.primary,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 36,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 1.2,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CardPaymentSheet {
  static Future<bool?> show(BuildContext context, {required String title}) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showCheckoutSheet<bool>(
      context: context,
      builder: (_) => _CardPaymentBody(title: title),
    );
  }
}

class _CardPaymentBody extends StatefulWidget {
  final String title;
  const _CardPaymentBody({required this.title});

  @override
  State<_CardPaymentBody> createState() => _CardPaymentBodyState();
}

class _CardPaymentBodyState extends State<_CardPaymentBody> {
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _formatExpiry(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    var next = digits;
    if (digits.length >= 3) {
      next = '${digits.substring(0, 2)}/${digits.substring(2, digits.length.clamp(2, 4))}';
    }
    if (next != value) {
      _expiry.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  bool _validLuhn(String digits) {
    if (digits.length < 13 || digits.length > 19) return false;
    var sum = 0;
    var alt = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  void _submit() {
    final digits = _number.text.replaceAll(RegExp(r'\D'), '');
    final expiry = _expiry.text.trim();
    final cvv = _cvv.text.trim();
    if (!_validLuhn(digits)) {
      setState(() => _error = 'رقم البطاقة غير صحيح');
      return;
    }
    final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(expiry);
    if (match == null) {
      setState(() => _error = 'أدخل تاريخ الانتهاء بصيغة MM/YY');
      return;
    }
    final month = int.parse(match.group(1)!);
    if (month < 1 || month > 12) {
      setState(() => _error = 'شهر الانتهاء غير صحيح');
      return;
    }
    if (cvv.length < 3) {
      setState(() => _error = 'أدخل رمز CVV');
      return;
    }
    Navigator.of(context).pop(true);
  }

  InputDecoration _field(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintTextDirection: TextDirection.ltr,
      filled: true,
      fillColor: AppTheme.background,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryDark, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutSheetFrame(
      title: widget.title,
      subtitle: 'أدخل بيانات البطاقة لإكمال الدفع',
      footer: CheckoutSheetButton(
        label: 'إكمال الدفع',
        onPressed: _submit,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _number,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              autofocus: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
                _CardNumberFormatter(),
              ],
              decoration: _field(
                'Card number',
                hint: '**** **** **** ****',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiry,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    onChanged: _formatExpiry,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: _field('MM/YY', hint: 'MM/YY'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _cvv,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: _field('CVV', hint: '***'),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFC62828),
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                ),
              ),
            ],
            const SizedBox(height: 18),
            const Text(
              'WE ACCEPT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppTheme.mutedText,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AcceptBadge('assets/images/payments/mada.svg', 46),
                const SizedBox(width: 12),
                _AcceptBadge('assets/images/payments/visa.svg', 52),
                const SizedBox(width: 12),
                _AcceptBadge('assets/images/payments/mastercard.svg', 42),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AcceptBadge extends StatelessWidget {
  final String asset;
  final double width;
  const _AcceptBadge(this.asset, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6EEE8)),
      ),
      child: SvgPicture.asset(asset, width: width, height: 22),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
