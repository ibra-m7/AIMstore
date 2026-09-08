import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/marquee_text.dart';
import '../../../shop/presentation/widgets/checkout_sheet.dart';
import '../../data/models/delivery_address.dart';
import '../../data/services/auth_session.dart';
import '../auth_flow.dart';
import '../manager/address_cubit.dart';
import '../pages/add_address_screen.dart';

class DeliveryAddressesSheet {
  static Future<void> show(BuildContext context) async {
    try {
      if (!AuthSession.instance.isLoggedIn) {
        await AuthFlow.requireLogin(
          context,
          message: AppStrings.guestAddressMessage,
        );
        return;
      }
      if (!context.mounted) return;
      final cubit = context.read<AddressCubit>();
      // لا ننتظر التحميل قبل فتح الشيت — يقلل ضغط الرسم عند الفتح.
      cubit.load();
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: false,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        useRootNavigator: true,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const _DeliveryAddressesBody(),
        ),
      );
    } catch (e, st) {
      debugPrint('DeliveryAddressesSheet.show failed: $e\n$st');
    }
  }
}

class _DeliveryAddressesBody extends StatelessWidget {
  const _DeliveryAddressesBody();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.52;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.deliveryTo,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: AppTheme.darkText,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            AppStrings.deliveryChooseAddress,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 12,
                    left: 14,
                    child: CheckoutSheetCloseButton(),
                  ),
                ],
              ),
              Expanded(
                child: BlocBuilder<AddressCubit, AddressState>(
                  builder: (context, state) {
                    if (state.loading && state.addresses.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.addresses.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            AppStrings.deliveryEmpty,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      itemCount: state.addresses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final address = state.addresses[index];
                        return _AddressCard(
                          address: address,
                          busy: state.busy,
                          onOpen: () => _openDetails(context, address),
                          onDelete: () => _confirmDelete(context, address),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: SafeArea(
                  top: false,
                  child: Align(
                    alignment: Alignment.center,
                    child: Material(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: () async {
                          final added = await Navigator.of(context).pushNamed(
                            AddAddressScreen.routeName,
                          );
                          if (added == true && context.mounted) {
                            context.read<AddressCubit>().load();
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFD4DDD6)),
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 0, 10, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryDark,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                AppStrings.deliveryAddNew,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.2,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context, DeliveryAddress address) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AddressCubit>(),
        child: _AddressDetailsSheet(address: address),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, DeliveryAddress address) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          AppStrings.deliveryDeleteConfirm,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
          ),
        ),
        content: const Text(
          AppStrings.deliveryDeleteBody,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            height: 1.45,
            color: AppTheme.mutedText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await context.read<AddressCubit>().remove(address.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            context.read<AddressCubit>().state.error ?? 'تعذّر الحذف',
            textAlign: TextAlign.center,
          ),
        ));
      }
    }
  }
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.busy,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: address.isDefault ? 3 : 1.2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              height: 1.25,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 6),
                          const Text(
                            'الحالي',
                            style: TextStyle(
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      height: 18,
                      child: MarqueeText(
                        text: address.subtitle.isEmpty
                            ? 'بدون وصف إضافي'
                            : address.subtitle,
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: busy ? null : onDelete,
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressDetailsSheet extends StatelessWidget {
  final DeliveryAddress address;

  const _AddressDetailsSheet({required this.address});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E6E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                AppStrings.deliveryCurrentDetails,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow('اسم الموقع', address.label),
              _detailRow('الوصف', address.subtitle.isEmpty ? '—' : address.subtitle),
              if (address.city != null) _detailRow('المدينة', address.city!),
              if (address.latitude != null && address.longitude != null)
                _detailRow(
                  'الإحداثيات',
                  '${address.latitude!.toStringAsFixed(5)} , ${address.longitude!.toStringAsFixed(5)}',
                ),
              _detailRow('عدد الطلبات من هنا', '${address.ordersCount}'),
              const SizedBox(height: 14),
              SizedBox(
                height: 42,
                child: FilledButton(
                  onPressed: address.isDefault
                      ? () => Navigator.pop(context)
                      : () async {
                          await context.read<AddressCubit>().select(address.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    address.isDefault
                        ? 'هذا هو عنوان التوصيل الحالي'
                        : AppStrings.deliveryUseThis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.mutedText,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
