import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// صف قائمة الملف الشخصي — أيقونة يمين، نص، سهم لليسار (<) للدخول.
class ProfileMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;

  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.showChevron = true,
  });

  static Widget forwardChevron({double size = 18}) {
    return Icon(
      Icons.chevron_left_rounded,
      size: size,
      color: AppTheme.mutedText.withValues(alpha: 0.55),
      textDirection: TextDirection.ltr,
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: AppTheme.mutedText.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showChevron)
            forwardChevron(),
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: row,
      ),
    );
  }
}
