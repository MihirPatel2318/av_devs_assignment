import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/app_exception.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<List<Product>> fetchProducts({int skip = 0, int limit = 20}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products?skip=$skip&limit=$limit'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        return products;
      } else {
        throw FetchDataException('Failed to load products: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw FetchDataException('Error loading products: $e');
    }
  }

  Future<List<Product>> searchProducts(String query, {int skip = 0, int limit = 20}) async {
    if (query.isEmpty) {
      return fetchProducts(skip: skip, limit: limit);
    }

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/search?q=$query&skip=$skip&limit=$limit'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        return products;
      } else {
        throw FetchDataException('Failed to search products: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw FetchDataException('Error searching products: $e');
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category, {int skip = 0, int limit = 20}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/category/$category?skip=$skip&limit=$limit'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        return products;
      } else {
        throw FetchDataException('Failed to load category products: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw FetchDataException('Error loading category products: $e');
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/categories'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => e.toString()).toList();
      } else {
        throw FetchDataException('Failed to load categories: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw FetchDataException('Error loading categories: $e');
    }
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/$id'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw FetchDataException('Failed to load product: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timeout');
    } catch (e) {
      throw FetchDataException('Error loading product: $e');
    }
  }
}
