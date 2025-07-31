import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/vehicle_marker.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  IconData _getVehicleIcon(String vehicle) {
    switch (vehicle.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'horse':
        return Icons.pets;
      case 'on_foot':
        return Icons.directions_walk;
      case 'bicycle':
        return Icons.directions_bike;
      default:
        return Icons.location_on;
    }
  }

  void _showMarkerDetails(BuildContext context, VehicleMarker marker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(marker.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Veículo:', marker.vehicle),
            _buildDetailRow('Bateria:', '${marker.battery}%'),
            _buildDetailRow('Status:', marker.emergency ? 'EMERGÊNCIA' : 'Normal'),
            _buildDetailRow('Data:', _formatDate(marker.date)),
            _buildDetailRow('Latitude:', marker.coordinates.latitude.toStringAsFixed(6)),
            _buildDetailRow('Longitude:', marker.coordinates.longitude.toStringAsFixed(6)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final markers = ModalRoute.of(context)!.settings.arguments as List<VehicleMarker>;
    
    if (markers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: const Center(child: Text('Nenhum marcador para exibir')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Marcadores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Legenda'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(Icons.directions_car, 'Carro'),
                      _buildLegendItem(Icons.pets, 'Cavalo'),
                      _buildLegendItem(Icons.directions_walk, 'A pé'),
                      _buildLegendItem(Icons.location_on, 'Outros'),
                      const SizedBox(height: 10),
                      _buildLegendItem(Icons.circle, 'Emergência', color: Colors.red),
                      _buildLegendItem(Icons.circle, 'Normal', color: Colors.blue),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            markers.first.coordinates.latitude,
            markers.first.coordinates.longitude,
          ),
          initialZoom: 15,
          onTap: (_, __) => Navigator.of(context).pop(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: markers.map((marker) => Marker(
              width: 40,
              height: 40,
              point: LatLng(
                marker.coordinates.latitude,
                marker.coordinates.longitude,
              ),
              child: GestureDetector(
                onTap: () => _showMarkerDetails(context, marker),
                child: Icon(
                  _getVehicleIcon(marker.vehicle),
                  color: marker.emergency ? Colors.red : Colors.blue,
                  size: 30,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Lista de Marcadores',
        child: const Icon(Icons.list),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Lista Completa de Marcadores',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: markers.length,
                        itemBuilder: (context, index) {
                          final marker = markers[index];
                          return ListTile(
                            leading: Icon(
                              _getVehicleIcon(marker.vehicle),
                              color: marker.emergency ? Colors.red : Colors.blue,
                            ),
                            title: Text(marker.name),
                            subtitle: Text(
                              '${marker.vehicle} - ${marker.battery}%'
                            ),
                            trailing: Text(
                              '${marker.coordinates.latitude.toStringAsFixed(4)}, '
                              '${marker.coordinates.longitude.toStringAsFixed(4)}'
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showMarkerDetails(context, marker);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}