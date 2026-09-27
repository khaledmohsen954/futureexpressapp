import '../models/shipment.dart';

/// UI-only shipment records; no customer details are fetched or persisted.
const sampleShipments = <Shipment>[
  Shipment(id: 'FX-2048', customer: 'أحمد محمد', address: 'حي الياسمين، الرياض', status: ShipmentStatus.inTransit, amount: '120'),
  Shipment(id: 'FX-2049', customer: 'سارة خالد', address: 'حي النرجس، الرياض', status: ShipmentStatus.pending, amount: '85'),
  Shipment(id: 'FX-2050', customer: 'محمد علي', address: 'حي الملقا، الرياض', status: ShipmentStatus.delivered, amount: '150'),
  Shipment(id: 'FX-2051', customer: 'فاطمة إبراهيم', address: 'حي العليا، الرياض', status: ShipmentStatus.pending, amount: '95'),
];
