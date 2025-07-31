import 'package:mapa_osm/models/coordinate.dart';
class VehicleMarker {
  final String id;
  final Coordinate coordinates;
  final String vehicle;
  final int battery;
  final DateTime date;
  final bool emergency;
  final String name;

  VehicleMarker({
    required this.id,
    required this.coordinates,
    required this.vehicle,
    required this.battery,
    required this.date,
    required this.emergency,
    required this.name,
  });

  factory VehicleMarker.fromJson(Map<String, dynamic> json, String ownerName) {
  return VehicleMarker(
    id: json['id'] ?? '',
    coordinates: Coordinate(
      latitude: (json['coordinates']['coordinates'][0] as num?)?.toDouble() ?? 0.0,
      longitude: (json['coordinates']['coordinates'][1] as num?)?.toDouble() ?? 0.0,
    ),
    vehicle: json['vehicle'] ?? 'unknown',
    battery: (json['battery'] as num?)?.toInt() ?? 0,
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    emergency: json['emergency'] ?? false,
    name: ownerName,
  );
}
}