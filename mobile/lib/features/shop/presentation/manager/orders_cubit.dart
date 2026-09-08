import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/services/orders_api.dart';
import '../../domain/entities/cart_bundle_line.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_entity.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({OrdersApi? api})
      : _api = api ?? OrdersApi.instance,
        super(const OrdersState());

  final OrdersApi _api;

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final orders = await _api.list();
      emit(state.copyWith(loading: false, orders: orders));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        emit(state.copyWith(loading: false, orders: const []));
        return;
      }
      if (state.orders.isNotEmpty) {
        emit(state.copyWith(loading: false, clearError: true));
        return;
      }
      emit(state.copyWith(loading: false, error: e.message));
    } catch (_) {
      if (state.orders.isNotEmpty) {
        emit(state.copyWith(loading: false, clearError: true));
        return;
      }
      emit(state.copyWith(loading: false, error: 'تعذّر تحميل الطلبات.'));
    }
  }

  Future<OrderEntity> placeOrder({
    required List<CartItem> items,
    List<CartBundleLine> bundles = const [],
    required String paymentMethod,
    int? addressId,
    String? notes,
    String? couponCode,
    List<String>? couponCodes,
    String fulfillmentType = 'now',
    DateTime? scheduledAt,
    String orderMethod = 'delivery',
  }) async {
    final order = await _api.create(
      items: items,
      bundles: bundles,
      paymentMethod: paymentMethod,
      addressId: addressId,
      notes: notes,
      couponCode: couponCode,
      couponCodes: couponCodes,
      fulfillmentType: fulfillmentType,
      scheduledAt: scheduledAt,
      orderMethod: orderMethod,
    );
    emit(state.copyWith(orders: [order, ...state.orders]));
    return order;
  }

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    final order = await _api.cancel(orderId, reason: reason);
    final updated = state.orders
        .map((item) => item.id == order.id ? order : item)
        .toList();
    emit(state.copyWith(orders: updated));
  }
}
