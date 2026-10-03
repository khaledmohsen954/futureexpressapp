import '../domain/shipment.dart';

/// Seed data for the UI preview. Live changes are owned by AppState.
const sampleShipments = <Shipment>[
  Shipment(
      id: 'FX-2048',
      customerAr: 'أحمد محمد',
      customerEn: 'Ahmed Mohammed',
      addressAr: 'حي الياسمين، الرياض',
      addressEn: 'Al Yasmin, Riyadh',
      customerPhone: '0551234567',
      paymentMethod: PaymentMethod.cash,
      status: ShipmentStatus.inTransit,
      amount: 120),
  Shipment(
      id: 'FX-2049',
      customerAr: 'سارة خالد',
      customerEn: 'Sarah Khaled',
      addressAr: 'حي النرجس، الرياض',
      addressEn: 'Al Narjis, Riyadh',
      customerPhone: '0552345678',
      paymentMethod: PaymentMethod.online,
      status: ShipmentStatus.delivered,
      amount: 85),
  Shipment(
      id: 'FX-2050',
      customerAr: 'محمد علي',
      customerEn: 'Mohammed Ali',
      addressAr: 'حي الملقا، الرياض',
      addressEn: 'Al Malqa, Riyadh',
      customerPhone: '0553456789',
      paymentMethod: PaymentMethod.online,
      status: ShipmentStatus.delivered,
      amount: 150),
  Shipment(
      id: 'FX-2051',
      customerAr: 'فاطمة إبراهيم',
      customerEn: 'Fatimah Ibrahim',
      addressAr: 'حي العليا، الرياض',
      addressEn: 'Al Olaya, Riyadh',
      customerPhone: '0554567890',
      paymentMethod: PaymentMethod.cash,
      status: ShipmentStatus.delivered,
      amount: 95),
];
