import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import 'checkout_sheet.dart';

class StcPaySheet {
  static Future<String?> show(BuildContext context, {String? initialPhone}) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showCheckoutSheet<String>(
      context: context,
      builder: (_) => _StcPayBody(initialPhone: initialPhone),
    );
  }
}

class _StcPayBody extends StatefulWidget {
  final String? initialPhone;
  const _StcPayBody({this.initialPhone});

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
    if (digits.startsWith('966')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length == 9 && digits.startsWith('5')) {
      return '0$digits';
    }
    return null;
  }

  void _submit() {
    final phone = _normalized(_ctrl.text);
    if (phone == null) {
      setState(() => _error = 'أدخل رقم جوال سعودي صحيح يبدأ بـ 05');
      return;
    }
    Navigator.of(context).pop(phone);
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutSheetFrame(
      title: 'STC Pay',
      subtitle: 'أدخل رقم الجوال المرتبط بمحفظتك',
      footer: CheckoutSheetButton(
        label: 'تحقق من الرقم',
        background: const Color(0xFF4F008C),
        onPressed: _submit,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F0FB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: SvgPicture.asset(
                'assets/images/payments/stc_pay.svg',
                height: 48,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              autofocus: false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'رقم الجوال',
                hintText: '05xxxxxxxx',
                hintTextDirection: TextDirection.ltr,
                filled: true,
                fillColor: AppTheme.background,
                prefixIcon: const Icon(
                  Icons.phone_iphone_rounded,
                  color: Color(0xFF4F008C),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primaryLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primaryLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF4F008C),
                    width: 1.6,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
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
