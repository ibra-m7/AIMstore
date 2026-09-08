import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import 'checkout_sheet.dart';

class CouponSheet {
  static Future<String?> show(
    BuildContext context, {
    String? initialCode,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showCheckoutSheet<String>(
      context: context,
      builder: (_) => _CouponBody(initialCode: initialCode),
    );
  }
}

class _CouponBody extends StatefulWidget {
  final String? initialCode;
  const _CouponBody({this.initialCode});

  @override
  State<_CouponBody> createState() => _CouponBodyState();
}

class _CouponBodyState extends State<_CouponBody> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _ctrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل كود الخصم', textAlign: TextAlign.center),
        ),
      );
      return;
    }
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.discount_rounded,
                                color: AppTheme.primaryDark,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'الخصومات والقسائم',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'بإمكانك إضافة قسيمة شرائية أو خصم',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.mutedText.withValues(alpha: 0.95),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 16,
                      child: Transform.translate(
                        offset: const Offset(0, -8),
                        child: const CheckoutSheetCloseButton(),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: false,
                        textAlign: TextAlign.right,
                        textCapitalization: TextCapitalization.characters,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9\-_]'),
                          ),
                          LengthLimitingTextInputFormatter(32),
                        ],
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'كود الخصم',
                          hintStyle: TextStyle(
                            color: AppTheme.mutedText.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: const BorderSide(
                              color: Color(0xFFDCE5DF),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: const BorderSide(
                              color: Color(0xFFDCE5DF),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryDark,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ApplyCouponChipButton(
                      filled: true,
                      onTap: _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
