part of 'app_routers_import.dart';

class AppRouters {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.supportScreen:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SupportScreen(),
        );
      case RoutesName.pickupScreen:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const PickupScreen(),
        );
      case RoutesName.sendReportScreen:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SendReportScreen(),
        );
      case RoutesName.deliveryFailureScreen:
        final shipmentId = settings.arguments;
        if (shipmentId is! String) {
          throw FlutterError(
            'The ${RoutesName.deliveryFailureScreen} route requires a String shipment ID.',
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DeliveryFailureScreen(shipmentId: shipmentId),
        );
      case RoutesName.shipmentDetailsScreen:
        final shipmentId = settings.arguments;
        if (shipmentId is! String) {
          throw FlutterError(
            'The ${RoutesName.shipmentDetailsScreen} route requires a String shipment ID.',
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ShipmentDetailsScreen(),
        );
      default:
        return null;
    }
  }
}
