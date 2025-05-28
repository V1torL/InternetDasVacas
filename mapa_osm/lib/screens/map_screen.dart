import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/coordinate.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List<Coordinate>? ?? [];

    final points = args.map((e) => LatLng(e.latitude, e.longitude)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: points.isNotEmpty ? points[0] : LatLng(0, 0),
          initialZoom: 5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (points.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: points,
                  color: Colors.blue,
                  strokeWidth: 4,
                ),
              ],
            ),
          if (points.length >= 3)
            PolygonLayer(
              polygons: [
                Polygon(
                  points: points,
                  borderColor: Colors.red,
                  borderStrokeWidth: 3,
                  color: Colors.red.withValues(
                    red: 255, 
                    green: 0, 
                    blue: 0, 
                    alpha: 128
                  ),
                ),
              ],
            ),
          MarkerLayer(
            markers: points.map(
              (point) {
                return Marker(
                  width: 40,
                  height: 40,
                  point: point,
                  child: const Icon(Icons.location_on, color: Colors.red),
                );
              },
            ).toList(),
          )
        ],
      ),
    );
  }
}
