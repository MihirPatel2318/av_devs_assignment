import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/analytics_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());
final analyticsServiceProvider = Provider((ref) => AnalyticsService());

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.fetchCategories();
});

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(analyticsServiceProvider),
  );
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ApiService _apiService;
  final AnalyticsService _analyticsService;
  final List<Product> _allProducts = [];
  int _currentSkip = 0;
  bool _hasMore = true;
  String _currentSearchQuery = '';
  String? _currentCategory;

  ProductsNotifier(this._apiService, this._analyticsService)
      : super(const AsyncValue.loading()) {
    loadInitialProducts();
  }

  Future<void> loadInitialProducts() async {
    state = const AsyncValue.loading();
    _currentSearchQuery = '';
    _currentCategory = null;
    try {
      final products = await _apiService.fetchProducts(skip: 0, limit: 20);
      _allProducts.clear();
      _allProducts.addAll(products);
      _currentSkip = 20;
      _hasMore = products.length == 20;
      state = AsyncValue.data(_allProducts);
    } catch (e, stack) {
      await _analyticsService.trackApiFailure();
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchProducts(String query) async {
    if (_currentSearchQuery == query) return;

    state = const AsyncValue.loading();
    _currentSearchQuery = query;
    _currentCategory = null;
    _currentSkip = 0;

    try {
      final products = await _apiService.searchProducts(query, skip: 0, limit: 20);
      _allProducts.clear();
      _allProducts.addAll(products);
      _currentSkip = 20;
      _hasMore = products.length == 20;
      state = AsyncValue.data(_allProducts);
    } catch (e, stack) {
      await _analyticsService.trackApiFailure();
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> filterByCategory(String? category) async {
    if (_currentCategory == category) return;

    state = const AsyncValue.loading();
    _currentCategory = category;
    _currentSearchQuery = '';
    _currentSkip = 0;

    try {
      final products = category == null
          ? await _apiService.fetchProducts(skip: 0, limit: 20)
          : await _apiService.fetchProductsByCategory(category, skip: 0, limit: 20);
      _allProducts.clear();
      _allProducts.addAll(products);
      _currentSkip = 20;
      _hasMore = products.length == 20;
      state = AsyncValue.data(_allProducts);
    } catch (e, stack) {
      await _analyticsService.trackApiFailure();
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMoreProducts() async {
    if (!_hasMore || state.isLoading) return;

    try {
      List<Product> newProducts;

      if (_currentSearchQuery.isNotEmpty) {
        newProducts = await _apiService.searchProducts(
          _currentSearchQuery,
          skip: _currentSkip,
          limit: 20,
        );
      } else if (_currentCategory != null) {
        newProducts = await _apiService.fetchProductsByCategory(
          _currentCategory!,
          skip: _currentSkip,
          limit: 20,
        );
      } else {
        newProducts = await _apiService.fetchProducts(
          skip: _currentSkip,
          limit: 20,
        );
      }

      _allProducts.addAll(newProducts);
      _currentSkip += 20;
      _hasMore = newProducts.length == 20;
      state = AsyncValue.data(List.from(_allProducts));
    } catch (e) {
      await _analyticsService.trackApiFailure();
    }
  }

  Future<void> refresh() async {
    if (_currentSearchQuery.isNotEmpty) {
      await searchProducts(_currentSearchQuery);
    } else if (_currentCategory != null) {
      await filterByCategory(_currentCategory);
    } else {
      await loadInitialProducts();
    }
  }

  bool get hasMore => _hasMore;
  String get currentSearchQuery => _currentSearchQuery;
  String? get currentCategory => _currentCategory;
}
