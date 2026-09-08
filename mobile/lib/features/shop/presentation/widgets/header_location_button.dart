import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/manager/address_cubit.dart';
import '../../../auth/presentation/widgets/delivery_addresses_sheet.dart';

/// زر الموقع مع اسم العنوان المختار — مشترك بين الرئيسية والأقسام.
class HeaderLocationButton extends StatelessWidget {
  const HeaderLocationButton({super.key, this.onImage = false});

  final bool onImage;

  Future<void> _open(BuildContext context) async {
    // انتظر انتهاء الإطار الحالي قبل فتح الشيت لتفادي تعارض الرسم/الأنيميشن.
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    try {
      await DeliveryAddressesSheet.show(context);
    } catch (e, st) {
      debugPrint('HeaderLocationButton open failed: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final name = state.selected?.headerName ?? AppStrings.homeLocationHome;
        final style = Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
              fontSize: 12.5,
            );
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _open(context),
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: AppScale.of(context).searchH,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: onImage ? AppTheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 2, end: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: style,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
