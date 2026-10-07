import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../data/repositories/daily_shipment_sequence_store.dart';
import '../../domain/shipment.dart';
import 'shipment_card.dart';

/// One list component powers the all, pending, and completed Figma states.
class ShipmentList extends StatefulWidget {
  const ShipmentList({
    super.key,
    required this.shipments,
    this.numberInTransitShipments = false,
    this.sequenceSource,
    this.sequenceStore,
  });

  final List<Shipment> shipments;
  final bool numberInTransitShipments;
  final List<Shipment>? sequenceSource;
  final ShipmentSequenceStore? sequenceStore;

  @override
  State<ShipmentList> createState() => _ShipmentListState();
}

class _ShipmentListState extends State<ShipmentList> {
  late final ShipmentSequenceStore _sequenceStore =
      widget.sequenceStore ?? DailyShipmentSequenceStore();
  Map<String, int> _sequences = const {};
  int _loadGeneration = 0;

  List<Shipment> get _sequenceSource =>
      widget.sequenceSource ?? widget.shipments;

  String _sourceSignature(ShipmentList list) =>
      (list.sequenceSource ?? list.shipments)
          .map((shipment) => '${shipment.id}:${shipment.orderId ?? ''}')
          .join('|');

  @override
  void initState() {
    super.initState();
    unawaited(_loadSequences());
  }

  @override
  void didUpdateWidget(covariant ShipmentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.numberInTransitShipments &&
        (!oldWidget.numberInTransitShipments ||
            _sourceSignature(oldWidget) != _sourceSignature(widget))) {
      unawaited(_loadSequences());
    }
  }

  Future<void> _loadSequences() async {
    if (!widget.numberInTransitShipments) return;
    final generation = ++_loadGeneration;
    final sequences = await _sequenceStore.assignNumbers(_sequenceSource);
    if (!mounted || generation != _loadGeneration) return;
    setState(() => _sequences = sequences);
  }

  @override
  Widget build(BuildContext context) {
    final shipments = [...widget.shipments];
    if (widget.numberInTransitShipments) {
      shipments.sort((left, right) {
        final leftSequence = _sequences[left.id];
        final rightSequence = _sequences[right.id];
        if (leftSequence != null && rightSequence != null) {
          return leftSequence.compareTo(rightSequence);
        }
        if (leftSequence != null) return -1;
        if (rightSequence != null) return 1;
        return DailyShipmentSequenceStore.compareByShipmentNumber(left, right);
      });
    }

    return Column(children: [
      for (final shipment in shipments)
        ShipmentCard(
          key: ValueKey(shipment.id),
          shipment: shipment,
          sequenceNumber:
              widget.numberInTransitShipments ? _sequences[shipment.id] : null,
        ),
      if (shipments.isEmpty)
        Padding(
          padding: const EdgeInsets.all(35),
          child: Center(child: Text(tr(context, AppLocaleKey.noShipments))),
        ),
    ]);
  }
}
