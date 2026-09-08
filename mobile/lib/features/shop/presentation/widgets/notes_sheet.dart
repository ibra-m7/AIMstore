import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'checkout_sheet.dart';

class NotesSheet {
  static Future<String?> show(
    BuildContext context, {
    String? initialNotes,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showCheckoutSheet<String>(
      context: context,
      builder: (_) => _NotesBody(initialNotes: initialNotes),
    );
  }
}

class _NotesBody extends StatefulWidget {
  final String? initialNotes;

  const _NotesBody({this.initialNotes});

  @override
  State<_NotesBody> createState() => _NotesBodyState();
}

class _NotesBodyState extends State<_NotesBody> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return CheckoutSheetFrame(
      title: 'ملاحظات الطلب',
      subtitle: 'أضف أي تفاصيل تساعدنا على تجهيز طلبك بدقة',
      footer: CheckoutSheetButton(
        label: 'حفظ الملاحظات',
        onPressed: _submit,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        child: TextField(
          controller: _ctrl,
          autofocus: false,
          maxLines: 5,
          minLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 1.45,
          ),
          decoration: InputDecoration(
            hintText: 'مثال: لا ترن الجرس، اترك الطلب عند الباب...',
            filled: true,
            fillColor: AppTheme.background,
            alignLabelWithHint: true,
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
                color: AppTheme.primaryDark,
                width: 1.6,
              ),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ),
    );
  }
}
