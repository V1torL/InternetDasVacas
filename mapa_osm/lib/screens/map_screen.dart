import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/coordinate.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pontos =
        ModalRoute.of(context)!.settings.arguments as List<Coordinate>;

    final List<LatLng> pontosLatLng = pontos
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: pontosLatLng.isNotEmpty
              ? pontosLatLng.first
              : LatLng(0, 0),
          initialZoom: 5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolygonLayer(
            polygons: [
              Polygon(
                points: pontosLatLng,
                borderColor: Colors.red,
                borderStrokeWidth: 3,
                color: const Color.fromARGB(100, 255, 0, 0),
              ),
            ],
          ),
          MarkerLayer(
            markers: pontosLatLng
                .map(
                  (p) => Marker(
                    width: 40,
                    height: 40,
                    point: p,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
