import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_storage_service.dart';

final cartStorageServiceProvider = Provider((ref) => CartStorageService());

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref.watch(cartStorageServiceProvider));
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final CartStorageService _storageService;

  CartNotifier(this._storageService) : super([]) {
    loadCart();
  }

  Future<void> loadCart() async {
    final items = await _storageService.loadCart();
    state = items;
  }

  void addToCart(Product product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final updatedItem = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + 1,
      );
      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }

    _storageService.saveCart(state);
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _storageService.saveCart(state);
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final updatedItem = state[index].copyWith(quantity: quantity);
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
      _storageService.saveCart(state);
    }
  }

  Future<void> clearCart() async {
    state = [];
    await _storageService.clearCart();
  }

  bool isInCart(int productId) {
    return state.any((item) => item.product.id == productId);
  }

  int getQuantity(int productId) {
    final item = state.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(id: 0, title: '', description: '', price: 0, rating: 0, thumbnail: '', images: []), quantity: 0),
    );
    return item.quantity;
  }

  double get totalPrice {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}
