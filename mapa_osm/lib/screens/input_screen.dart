import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/coordinate.dart';
import '../models/vehicle_marker.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final List<VehicleMarker> localMarkers = [];
  List<VehicleMarker> serverMarkers = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();
  final TextEditingController batteryController = TextEditingController();
  bool emergencyValue = false;
  final Uuid uuid = const Uuid();

  Future<void> _carregarDadosServidor() async {
    const String url = 'https://dev.idals.com.br/pm-api/pm_mg/';

    const String token = 'idals';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] == null) throw Exception('Resposta sem dados');
        
        setState(() {
          serverMarkers = [];
          jsonResponse['data'].forEach((ownerName, vehicles) {
            for (var vehicleData in vehicles as List) {
              serverMarkers.add(VehicleMarker.fromJson(vehicleData, ownerName));
            }
          });
        });
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: ${e.toString()}')),
      );
    }
  }

  void _adicionarMarcadorLocal() {
    final double? lat = double.tryParse(latController.text);
    final double? lon = double.tryParse(lonController.text);
    final int? battery = int.tryParse(batteryController.text);

    if (lat == null || lon == null || battery == null || 
        nameController.text.isEmpty || vehicleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente')),
      );
      return;
    }

    setState(() {
      localMarkers.add(VehicleMarker(
        id: uuid.v4(),
        coordinates: Coordinate(latitude: lat, longitude: lon),
        vehicle: vehicleController.text,
        battery: battery,
        date: DateTime.now(),
        emergency: emergencyValue,
        name: nameController.text,
      ));
      
      nameController.clear();
      vehicleController.clear();
      latController.clear();
      lonController.clear();
      batteryController.clear();
    });
  }

  void _mostrarMapa() {
    final todosMarcadores = [...serverMarkers, ...localMarkers];
    
    if (todosMarcadores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum marcador para exibir')),
      );
      return;
    }

    Navigator.pushNamed(
      context, 
      '/map', 
      arguments: todosMarcadores,
    );
  }

  @override
  void initState() {
    super.initState();
    _carregarDadosServidor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciador de Marcadores')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome do Marcador'),
            ),
            TextField(
              controller: vehicleController,
              decoration: const InputDecoration(labelText: 'Tipo de Veículo'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: lonController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TextField(
              controller: batteryController,
              decoration: const InputDecoration(labelText: 'Bateria (%)'),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text('Emergência'),
              value: emergencyValue,
              onChanged: (value) => setState(() => emergencyValue = value),
            ),

            ElevatedButton(
              onPressed: _adicionarMarcadorLocal,
              child: const Text('Adicionar Marcador Local'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _carregarDadosServidor,
              child: const Text('Atualizar Dados do Servidor'),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Locais'),
                        Tab(text: 'Servidor'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildListaMarcadores(localMarkers, true),
                          _buildListaMarcadores(serverMarkers, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ElevatedButton(
              onPressed: _mostrarMapa,
              child: const Text('Visualizar Todos no Mapa'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaMarcadores(List<VehicleMarker> markers, bool podeRemover) {
    return ListView.builder(
      itemCount: markers.length,
      itemBuilder: (context, index) {
        final marker = markers[index];
        return ListTile(
          title: Text('${marker.name} (${marker.vehicle})'),
          subtitle: Text(
            'Lat: ${marker.coordinates.latitude.toStringAsFixed(6)}\n'
            'Lon: ${marker.coordinates.longitude.toStringAsFixed(6)}\n'
            'Bateria: ${marker.battery}% ${marker.emergency ? '⚠️' : ''}'
          ),
          trailing: podeRemover
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => localMarkers.removeAt(index)),
                )
              : null,
        );
      },
    );
  }
}