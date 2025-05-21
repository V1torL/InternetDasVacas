import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapaOSM(),
    );
  }
}

class MapaOSM extends StatelessWidget {
  final LatLng dublin = LatLng(51.51868093513547, -0.12835376940892318);
  final LatLng londres = LatLng(53.33360293799854, -6.284001062079881);
  final LatLng ctan = LatLng(-21.104110841982546, -44.24970830717694);
  final LatLng cap = LatLng(-20.52155964929225, -43.74416777366398);
  final LatLng lamim = LatLng(-20.790326844953686, -43.47443215735805);
  final LatLng rj = LatLng(-22.907465659173052, -43.20574169408325);
  final LatLng sp = LatLng(-23.557497353028644, -46.62147671024337);
  final LatLng bh = LatLng(-19.919425967126692, -43.96407193380979);
  final LatLng vitoria = LatLng(-20.31941721282774, -40.335630536251664);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: lamim,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: dublin,
                width: 10,
                height: 10,
                child: Image.asset('assets/iconePino.png'),
              ),
              Marker(
                point: londres,
                width: 10,
                height: 10,
                child: Image.asset('assets/iconePino.png'),
              ),
              Marker(
                point: ctan,
                width: 10,
                height: 10,
                child: Image.asset('assets/iconePino.png'),
              ),
              Marker(
                point: cap,
                width: 10,
                height: 10,
                child: Image.asset('assets/iconePino.png'),
              ),
              Marker(
                point: lamim,
                width: 10,
                height: 10,
                child: Image.asset('assets/icone.png'),
              ),
            ],
          ),
          PolygonLayer(
            polygons: [
              Polygon(
                points: [
                  lamim,
                  cap,
                  ctan,
                ],
                borderColor: Colors.red,
                borderStrokeWidth: 1,
                hitValue: {
                  'title': 'Poligono de Lamim / CAP / CTAN',
                  'subtitle': 'Ligação entre as cidades de Lamim, Ouro Branco e SJDR',
                },
              ),
              /*Polygon(
                points: [
                  bh,
                  sp,
                  rj,
                  vitoria,
                ],
                color:  Colors.red,
                borderColor: Colors.black,
                borderStrokeWidth: 2,
                hitValue: (
                  title: 'Poligono ligando as capitais do sudeste',
                  subtitle: 'Ligação entre as capitais do sudeste',
                ),
              ),*/
              Polygon(
                points: [
                  rj,
                  sp,
                  bh,
                  vitoria,
                ].map((latlng) => LatLng(latlng.latitude, latlng.longitude)).toList(),
                pattern: const StrokePattern.dotted(),
                holePointsList: [ 
                  [
                    lamim,
                    cap,
                    ctan,
                  ],
                ],
                borderStrokeWidth: 2,
                borderColor: Colors.orange,
                color: Colors.orange.withAlpha(128),
                label: 'Ligação entre as capitais do sudeste',
                rotateLabel: true,
                labelPlacement: PolygonLabelPlacement.centroid,
                labelStyle: const TextStyle(color: Colors.black),
                hitValue: (
                  title: 'Buraco entre as cidades de Lamim, Ouro Branco e SJDR',
                  subtitle: 'Ligação entre as cidades de Lamim, Ouro Branco e SJDR',
                ),
              ),
            ],
          ),
          PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    dublin,
                    londres,
                  ],
                  strokeWidth: 2,
                  color: Colors.red,
                  hitValue: (
                    title: 'Linha entre duas cidades',
                    subtitle: 'Ligação entre as cidades de Dublin e Londres',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

