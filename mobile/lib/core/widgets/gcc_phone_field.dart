import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/gcc_phone.dart';

class GccPhoneField extends StatelessWidget {
  final String countryCode;
  final ValueChanged<String> onCountryChanged;
  final TextEditingController nationalController;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;

  const GccPhoneField({
    super.key,
    required this.countryCode,
    required this.onCountryChanged,
    required this.nationalController,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  Future<void> _pickCountry(BuildContext context) async {
    final selected = await showModalBottomSheet<GccPhoneCountry>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.mutedText.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Text(
                  'اختر الدولة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkText,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: GccPhone.countries.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: AppTheme.primaryLight.withValues(alpha: 0.45),
                  ),
                  itemBuilder: (context, index) {
                    final item = GccPhone.countries[index];
                    final isSelected = item.code == countryCode;
                    return ListTile(
                      leading: Text(item.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      trailing: Text(
                        item.dial,
                        style: TextStyle(
                          color: AppTheme.mutedText.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () => Navigator.pop(sheetContext, item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      onCountryChanged(selected.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final country = GccPhone.countryByCode(countryCode);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primarySurface.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryLight.withValues(alpha: 0.9),
          ),
        ),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _pickCountry(context),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppTheme.primaryLight.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(country.flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        country.dial,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppTheme.mutedText.withValues(alpha: 0.85),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: nationalController,
                keyboardType: TextInputType.phone,
                textInputAction: textInputAction,
                onFieldSubmitted: onFieldSubmitted == null
                    ? null
                    : (_) => onFieldSubmitted!(),
                maxLength: country.maxLength + 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                validator: validator,
                decoration: InputDecoration(
                  hintText: country.placeholder,
                  counterText: '',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
