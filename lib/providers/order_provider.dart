import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/order_storage_service.dart';

final orderStorageServiceProvider = Provider((ref) => OrderStorageService());

final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return OrdersNotifier(ref.watch(orderStorageServiceProvider));
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderStorageService _storageService;

  OrdersNotifier(this._storageService) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _storageService.loadOrders();
      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      await _storageService.saveOrder(order);
      await loadOrders();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  double get totalSpent {
    return state.maybeWhen(
      data: (orders) => orders.fold(0.0, (sum, order) => sum + order.totalAmount),
      orElse: () => 0.0,
    );
  }

  int get totalOrders {
    return state.maybeWhen(
      data: (orders) => orders.length,
      orElse: () => 0,
    );
  }
}
