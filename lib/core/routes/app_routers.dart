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
        final report = settings.arguments;
        if (report is! DailyReport) {
          throw FlutterError(
            'The ${RoutesName.sendReportScreen} route requires a DailyReport.',
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => DailyReportCubit(
              repository: sl<DailyReportRepository>(),
            )..setSummary(report),
            child: const SendReportScreen(),
          ),
        );
      case RoutesName.deliveryFailureScreen:
        final shipment = settings.arguments;
        if (shipment is! Shipment) {
          throw FlutterError(
            'The ${RoutesName.deliveryFailureScreen} route requires a Shipment.',
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => ShipmentStatusCubit(
              repository: sl<ShipmentsRepository>(),
            ),
            child: DeliveryFailureScreen(shipment: shipment),
          ),
        );
      case RoutesName.shipmentDetailsScreen:
        final shipment = settings.arguments;
        if (shipment is! Shipment) {
          throw FlutterError(
            'The ${RoutesName.shipmentDetailsScreen} route requires a Shipment.',
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => ShipmentStatusCubit(
              repository: sl<ShipmentsRepository>(),
            ),
            child: ShipmentDetailsScreen(shipment: shipment),
          ),
        );
      default:
        return null;
    }
  }
}
