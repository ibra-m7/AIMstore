import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

enum OrderMethod { delivery, pickup }

class OrderMethodToggle extends StatelessWidget {
  final OrderMethod value;
  final ValueChanged<OrderMethod> onChanged;
  final bool pickupEnabled;

  const OrderMethodToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.pickupEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!pickupEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFEA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleChip(
              label: 'توصيل',
              icon: Icons.delivery_dining_outlined,
              selected: value == OrderMethod.delivery,
              onTap: () => onChanged(OrderMethod.delivery),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ToggleChip(
              label: 'استلم بنفسك',
              icon: Icons.storefront_outlined,
              selected: value == OrderMethod.pickup,
              onTap: () => onChanged(OrderMethod.pickup),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? AppTheme.primaryDark : AppTheme.mutedText,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 13,
                    color: selected ? AppTheme.primaryDark : AppTheme.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
