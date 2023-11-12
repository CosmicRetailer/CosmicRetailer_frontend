import 'package:d_allegro/auth.dart';
import 'package:dio/dio.dart';

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers["Authorization"] = "Bearer ${dioAuth!.token}";
    handler.next(options);
  }
}

CosmicRetailerAuth? dioAuth;

Dio createDio() {
  Dio dio = Dio();
  dio.interceptors.add(HeaderInterceptor());
  return dio;
}

final Dio dio = createDio();

const String apiURL = 'https://cosmicretailer.onrender.com';
