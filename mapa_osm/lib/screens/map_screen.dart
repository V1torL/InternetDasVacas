import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/coordinate.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pontos = ModalRoute.of(context)!.settings.arguments as List<Coordinate>;

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
          onTap: (tapPosition, latlng) {
            const double distanciaMaxima = 0.0005;
            bool isInside = _isPointInsidePolygon(latlng, pontosLatLng);

            bool isNearMarker = pontosLatLng.any((p) {
              final distancia = (p.latitude - latlng.latitude).abs() + (p.longitude - latlng.longitude).abs();
              return distancia < distanciaMaxima;
            });

            if (isInside || isNearMarker) {
              _openTouchedGonsModal(context, 'onTap', latlng, pontosLatLng);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ponto fora do polígono.')),
              );
            }
          },
          onLongPress: (tapPosition, latlng) {
            _openTouchedGonsModal(context, 'onLongPress', latlng, pontosLatLng);
          },
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

  void _openTouchedGonsModal(
    BuildContext context,
    String eventType,
    LatLng coords,
    List<LatLng> pontosLatLng,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'Evento: $eventType',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Local tocado:'),
              Text('Latitude: ${coords.latitude}'),
              Text('Longitude: ${coords.longitude}'),
              const SizedBox(height: 12),
              const Text(
                'Pontos do polígono:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: pontosLatLng.length,
                  itemBuilder: (context, index) {
                    final ponto = pontosLatLng[index];
                    return Text(
                        'Ponto ${index + 1}: (${ponto.latitude}, ${ponto.longitude})');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

bool _isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
  int intersections = 0;
  for (int i = 0; i < polygon.length; i++) {
    LatLng vertex1 = polygon[i];
    LatLng vertex2 = polygon[(i + 1) % polygon.length];

    if (((vertex1.longitude > point.longitude) != (vertex2.longitude > point.longitude)) &&
        (point.latitude < (vertex2.latitude - vertex1.latitude) * (point.longitude - vertex1.longitude) /
                (vertex2.longitude - vertex1.longitude) +
            vertex1.latitude)) {
      intersections++;
    }
  }
  return (intersections % 2) != 0;
}


