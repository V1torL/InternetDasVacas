import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../hooks/auth_provider.dart';
import '../models/vehicle_marker.dart';
import '../hooks/server_data.dart';
import 'loading_screen.dart';
import 'package:mapa_osm/models/coordinate.dart';

class VehicleIcons {
  static const String basePath = 'assets/images/';
  
  static String getIconPath(String vehicle, bool isEmergency) {
    final color = isEmergency ? 'red' : 'green';
    switch (vehicle.toLowerCase()) {
      case 'car':
        return '${basePath}car_$color.png';
      case 'horse':
        return '${basePath}horse_$color.png';
      case 'on_foot':
        return '${basePath}walk_$color.png';
      case 'motorcycle':
        return '${basePath}bike_$color.png';
      default:
        return '${basePath}walk_$color.png';
    }
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final VehicleMarkerData serverData = useVehicleMarkerData(context: context);
  bool _initialLoadCompleted = false;

  static const double pathWidth = 2.0;
  static const double dotSize = 5.0;
  static const double markerSize = 40.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await serverData.loadData();
    if (mounted) {
      setState(() {
        _initialLoadCompleted = true;
      });
    }
  }

  void _refreshData() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          nextScreen: const MapScreen(),
          message: 'Atualizando dados...',
        ),
      ),
    );
  }

  Widget _getVehicleIcon(VehicleMarker marker) {
    return Image.asset(
      VehicleIcons.getIconPath(marker.vehicle, marker.emergency),
      width: markerSize,
      height: markerSize,
      fit: BoxFit.contain,
    );
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

  Widget _buildLegendItem(Widget icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Map<String, List<VehicleMarker>> _groupMarkersByName() {
    final grouped = <String, List<VehicleMarker>>{};
    for (final marker in serverData.markers) {
      grouped.putIfAbsent(marker.name, () => []).add(marker);
    }
    return grouped;
  }

  Color _getColorByEmergencyStatus(bool isEmergency) {
    return isEmergency ? Colors.red : Colors.green;
  }

  List<Marker> _createAllMarkers() {
    final markers = <Marker>[];
    final grouped = _groupMarkersByName();
    
    grouped.forEach((name, markersList) {
      final isEmergency = markersList.last.emergency;
      final color = _getColorByEmergencyStatus(isEmergency);
      
      markers.addAll(markersList.sublist(0, markersList.length - 1).map((m) =>
          Marker(
            width: 16,
            height: 16,
            point: LatLng(m.coordinates.latitude, m.coordinates.longitude),
            child: GestureDetector(
              onTap: () => _showMarkerDetails(context, m),
              child: Container(
                width: dotSize * 2,
                height: dotSize * 2,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          )));
      
      final last = markersList.last;
      markers.add(Marker(
        width: 40,
        height: 40,
        point: LatLng(last.coordinates.latitude, last.coordinates.longitude),
        child: GestureDetector(
          onTap: () => _showMarkerDetails(context, last),
          child: _getVehicleIcon(last),
        ),
      ));
    });
    
    return markers;
  }

  void _logout() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.logout();
    Navigator.pushReplacementNamed(context, '/login');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Você saiu do sistema')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (serverData.isLoading && !_initialLoadCompleted) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Carregando dados do servidor...'),
            ],
          ),
        ),
      );
    }

    if (serverData.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Sair do sistema',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Erro ao carregar dados'),
              Text(serverData.error!),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (serverData.markers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Sair do sistema',
            ),
          ],
        ),
        body: const Center(
          child: Text('Carregando Marcadores...'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Atualizar dados',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              final exampleMarker = VehicleMarker(
                id: 'some_id',
                name: 'Exemplo',
                vehicle: 'car',
                coordinates: Coordinate(latitude: 0, longitude: 0),
                battery: 100,
                emergency: false,
                date: DateTime.now(),
              );
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Legenda'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLegendItem(
                        _getVehicleIcon(exampleMarker),
                        'Carro',
                      ),
                      _buildLegendItem(
                        _getVehicleIcon(VehicleMarker(
                          id: 'some_id',
                          name: 'Exemplo',
                          vehicle: 'horse',
                          coordinates: Coordinate(latitude: 0, longitude: 0),
                          battery: 100,
                          emergency: false,
                          date: DateTime.now(),
                        )),
                        'Cavalo',
                      ),
                      _buildLegendItem(
                        _getVehicleIcon(VehicleMarker(
                          id: 'some_id',
                          name: 'Exemplo',
                          vehicle: 'on_foot',
                          coordinates: Coordinate(latitude: 0, longitude: 0),
                          battery: 100,
                          emergency: false,
                          date: DateTime.now(),
                        )),
                        'A pé',
                      ),
                      _buildLegendItem(
                        _getVehicleIcon(VehicleMarker(
                          id: 'some_id',
                          name: 'Exemplo',
                          vehicle: 'bicycle',
                          coordinates: Coordinate(latitude: 0, longitude: 0),
                          battery: 100,
                          emergency: false,
                          date: DateTime.now(),
                        )),
                        'Moto',
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        'Emergência',
                      ),
                      _buildLegendItem(
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        'Normal',
                      ),
                      _buildLegendItem(
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        'Pontos anteriores',
                      ),
                    ],
                  ),
                ),
              );
            },
            tooltip: 'Mostrar legenda',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair do sistema',
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-18.5122, -44.5550),
          initialZoom: 5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.seuapp.nome',
          ),
          ..._groupMarkersByName().entries.map((entry) {
            final isEmergency = entry.value.last.emergency;
            return PolylineLayer(
              polylines: [
                Polyline(
                  points: entry.value
                      .map((m) => LatLng(m.coordinates.latitude, m.coordinates.longitude))
                      .toList(),
                  color: _getColorByEmergencyStatus(isEmergency),
                  strokeWidth: pathWidth,
                ),
              ],
            );
          }),
          MarkerLayer(
            markers: _createAllMarkers(),
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
              final latestMarkers = _groupMarkersByName()
                  .values
                  .map((list) => list.last)
                  .toList();
              
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Últimos Marcadores de Cada Veículo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: latestMarkers.length,
                        itemBuilder: (context, index) {
                          final marker = latestMarkers[index];
                          return ListTile(
                            leading: _getVehicleIcon(marker),
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
}