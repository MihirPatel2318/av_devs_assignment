import 'dart:io';
import 'package:http/http.dart' as http;
import 'app_exception.dart';

class ErrorHandler {
  static AppException handleError(dynamic error) {
    if (error is SocketException) {
      return NoInternetException('Please check your internet connection');
    } else if (error is HttpException) {
      return FetchDataException('Could not find the server');
    } else if (error is FormatException) {
      return FetchDataException('Bad response format');
    } else if (error is TimeoutException) {
      return TimeoutException('Request took too long');
    } else {
      return FetchDataException('Unexpected error occurred');
    }
  }

  static AppException handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return AppException();
      case 400:
        return BadRequestException('Bad request');
      case 401:
      case 403:
        return UnauthorisedException('Unauthorized access');
      case 404:
        return FetchDataException('Resource not found');
      case 500:
      default:
        return FetchDataException('Server error: ${response.statusCode}');
    }
  }

  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.toString();
    } else if (error is SocketException) {
      return 'No Internet Connection';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
