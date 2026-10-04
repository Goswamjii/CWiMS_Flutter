import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

final routerServiceProvider = Provider((ref) => RouterService(ref));

class RouterService {
  final Ref _ref;

  RouterService(this._ref);

  Future<Response> getMyRouters() async {
    final dio = _ref.read(apiClientProvider).dio;

    return await dio.get('/Router');
  }

  Future<Response> createRouter({
    required String routerName,
    required String ssid,
    required String macAddress,
    required String ipAddress,
    required String location,
  }) async {
    final dio = _ref.read(apiClientProvider).dio;

    return await dio.post('/Router', data: {
      'routerName': routerName,
      'ssid': ssid,
      'macAddress': macAddress,
      'ipAddress': ipAddress,
      'location': location,
    });
  }
  Future<Response> updateRouter({
    required int id,
    required String routerName,
    required String ssid,
    required String macAddress,
    required String ipAddress,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    final dio = _ref.read(apiClientProvider).dio;

    return await dio.put(
      '/Router/$id',
      data: {
        'routerName': routerName,
        'ssid': ssid,
        'macAddress': macAddress,
        'ipAddress': ipAddress,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }  Future<Response> getDeviceCount(int routerId) async {
    final dio = _ref.read(apiClientProvider).dio;

    return await dio.get('/Device/count/$routerId');
  }
  Future<Response> deleteRouter(int id) async {
    final dio = _ref.read(apiClientProvider).dio;

    return await dio.delete('/Router/$id');



  }
  String getErrorMessage(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final errors = responseData['errors'];

        if (errors is Map<String, dynamic>) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }

        if (responseData['message'] != null) {
          return responseData['message'].toString();
        }
      }

      if (error.response?.statusCode == 400) {
        return 'Invalid router details.';
      }

      if (error.response?.statusCode == 401) {
        return 'Session expired. Please login again.';
      }

      if (error.response?.statusCode == 404) {
        return 'Router not found.';
      }

      return 'Unable to connect to server.';
    }

    return 'Something went wrong.';
  }
  Future<Response> getNetworkHealth(int routerId) async {
    final dio = _ref.read(apiClientProvider).dio;
    return await dio.get('/NetworkHealth/$routerId');
  }
  Future<Response> checkNetworkHealth(int routerId) async {
    final dio = _ref.read(apiClientProvider).dio;
    return await dio.post('/NetworkHealth/check/$routerId');
  }
  Future<Response> getTodayNetworkHealth(int routerId) async {
    final dio = _ref.read(apiClientProvider).dio;
    return await dio.get('/NetworkHealth/today/$routerId');
  }
}
