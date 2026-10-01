import 'package:futureexpressapp/core/network/api_consumer.dart';
import 'package:futureexpressapp/core/network/end_points.dart';
import 'package:futureexpressapp/features/shipments/data/repositories/shipments_repository.dart';

class FakeShipmentsApiConsumer implements ApiConsumer {
  FakeShipmentsApiConsumer(
    this.pages, {
    this.postResponse,
    Map<String, dynamic>? getResponses,
  }) : getResponses = {
          EndPoints.v3Statuses: testStatusesResponse,
          ...?getResponses,
        };

  final Map<int, Map<String, dynamic>> pages;
  final dynamic postResponse;
  final Map<String, dynamic> getResponses;
  final requestedPages = <int>[];
  final requestedPaths = <String>[];
  final requestedQueries = <Map<String, dynamic>?>[];
  final requestedAuth = <bool>[];
  String? postedPath;
  Map<String, dynamic>? postedBody;
  bool? postedAsFormData;
  bool? postedRequiresAuth;

  ShipmentsRepository createRepository() => ShipmentsRepository(this);

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = false,
  }) async {
    requestedPaths.add(path);
    requestedQueries.add(
      queryParameters == null
          ? null
          : Map<String, dynamic>.from(queryParameters),
    );
    requestedAuth.add(requiresAuth);
    final response = getResponses[path];
    if (response != null) return response;
    final page = queryParameters?['page'] as int? ?? 1;
    requestedPages.add(page);
    final pageResponse = pages[page] ??
        {
          'orders': {'data': <dynamic>[]},
          'pagination': {
            'current_page': page,
            'last_page': page,
            'total': 0,
          },
        };
    final statusId = queryParameters?['status_id'] as int?;
    if (statusId == null) return pageResponse;
    final orders = pageResponse['orders'];
    final data = orders is Map ? orders['data'] : null;
    final filteredOrders = data is List
        ? data.where((order) {
            if (order is! Map) return false;
            final orderStatusId = order['status_id'];
            return orderStatusId == statusId ||
                (orderStatusId is String &&
                    int.tryParse(orderStatusId) == statusId);
          }).toList(growable: false)
        : <dynamic>[];
    final pagination = pageResponse['pagination'];
    return {
      ...pageResponse,
      'orders': {
        if (orders is Map) ...orders,
        'data': filteredOrders,
      },
      'pagination': {
        if (pagination is Map) ...pagination,
        'total': filteredOrders.length,
      },
    };
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isFormData = false,
    bool requiresAuth = true,
    bool showToast = true,
  }) async {
    postedPath = path;
    postedBody = body;
    postedAsFormData = isFormData;
    postedRequiresAuth = requiresAuth;
    return postResponse;
  }

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      null;

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool showToast = true,
  }) async =>
      null;
}

Map<String, dynamic> shipmentsResponse(
  List<Map<String, dynamic>> orders, {
  required int page,
  required int lastPage,
  int? total,
}) =>
    {
      'success': 1,
      'orders': {'data': orders},
      'pagination': {
        'current_page': page,
        'last_page': lastPage,
        'total': total ?? orders.length,
      },
    };

const testStatusesResponse = {
  'success': 1,
  'statuses': [
    {'id': 35, 'title': 'New Order', 'title_ar': 'طلب جديد'},
    {
      'id': 327,
      'title': 'Received from the branch',
      'title_ar': 'تم الاستلام من الفرع',
    },
    {'id': 17, 'title': 'Out of Dlivery', 'title_ar': 'خارج للتوصيل'},
    {'id': 220, 'title': 'Delivered', 'title_ar': 'تم التوصيل'},
    {'id': 34, 'title': 'Delivery Failed', 'title_ar': 'تعذر التسليم'},
    {'id': 18, 'title': 'no answer', 'title_ar': 'لا يرد'},
    {'id': 330, 'title': 'Refused to receive', 'title_ar': 'رفض الاستلام'},
  ],
};

Map<String, dynamic> testOrder(
  String id,
  int statusId, {
  String? orderId,
  String clientName = 'Customer',
}) =>
    {
      'id': id,
      'order_id': orderId,
      'status_id': statusId,
      'client_name': clientName,
      'client_phone': '0501234567',
      'client_city': 'Riyadh',
      'client_city_ar': 'الرياض',
      'amount': '195.00',
      'amount_paid': 0,
    };

FakeShipmentsApiConsumer createTestShipmentsApi() => FakeShipmentsApiConsumer({
      1: shipmentsResponse([
        testOrder('FX-2048', 17),
        testOrder('FX-2049', 327),
        testOrder('FX-2050', 220),
        testOrder('FX-2051', 34),
      ], page: 1, lastPage: 1, total: 4),
    });
