import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/vehicle_marker.dart';

VehicleMarkerData useVehicleMarkerData({required BuildContext context}) {
  final List<VehicleMarker> serverMarkers = [];
  bool isLoading = false;
  String? error;

  Future<void> loadData() async {
    const String url = 'https://dev.idals.com.br/pm-api/pm_mg/';
    const String token = 'idals';
    
    isLoading = true;
    error = null;
    
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
        
        serverMarkers.clear();
        jsonResponse['data'].forEach((ownerName, vehicles) {
          for (var vehicleData in vehicles as List) {
            serverMarkers.add(VehicleMarker.fromJson(
              vehicleData, 
              ownerName.toString()
              )
            );
          }
        });
      } else {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      error = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: ${e.toString()}')),
        );
      }
    } finally {
      isLoading = false;
    }
  }

  return VehicleMarkerData(
    markers: serverMarkers,
    isLoading: isLoading,
    error: error,
    loadData: loadData,
  );
}

class VehicleMarkerData {
  final List<VehicleMarker> markers;
  final bool isLoading;
  final String? error;
  final Future<void> Function() loadData;

  VehicleMarkerData({
    required this.markers,
    required this.isLoading,
    required this.error,
    required this.loadData,
  });
}