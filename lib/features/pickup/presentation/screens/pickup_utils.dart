import 'package:futureexpressapp/features/shipments/domain/shipment.dart';
import 'package:futureexpressapp/features/pickup/presentation/widgets/pickup_source_segment.dart';

Set<String> pickupOrderCodes(Shipment shipment) => {
      shipment.id,
      if (shipment.orderId != null) shipment.orderId!,
      if (shipment.trackingNumber != null) shipment.trackingNumber!,
      if (shipment.referenceNumber != null) shipment.referenceNumber!,
    }.map((value) => value.trim()).where((value) => value.isNotEmpty).toSet();

String pickupOrderId(Shipment shipment) => shipment.orderId ?? shipment.id;

PickupSource pickupSourceForShipment(Shipment shipment) =>
    shipment.apiStatusId == PickupSource.merchant.statusId
        ? PickupSource.merchant
        : PickupSource.customer;
