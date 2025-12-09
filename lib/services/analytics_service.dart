import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const String _viewsPrefix = 'product_views_';
  static const String _apiFailuresKey = 'api_failures_count';
  static const String _cartAbandonmentKey = 'cart_abandonment_count';

  Future<void> trackProductView(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_viewsPrefix$productId';
    final views = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, views + 1);
  }

  Future<Map<int, int>> getMostViewedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_viewsPrefix));
    final Map<int, int> productViews = {};

    for (final key in keys) {
      final productId = int.tryParse(key.replaceFirst(_viewsPrefix, ''));
      if (productId != null) {
        productViews[productId] = prefs.getInt(key) ?? 0;
      }
    }

    return productViews;
  }

  Future<void> trackApiFailure() async {
    final prefs = await SharedPreferences.getInstance();
    final failures = prefs.getInt(_apiFailuresKey) ?? 0;
    await prefs.setInt(_apiFailuresKey, failures + 1);
  }

  Future<int> getApiFailuresCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_apiFailuresKey) ?? 0;
  }

  Future<void> trackCartAbandonment() async {
    final prefs = await SharedPreferences.getInstance();
    final abandonments = prefs.getInt(_cartAbandonmentKey) ?? 0;
    await prefs.setInt(_cartAbandonmentKey, abandonments + 1);
  }

  Future<int> getCartAbandonmentCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_cartAbandonmentKey) ?? 0;
  }
}
