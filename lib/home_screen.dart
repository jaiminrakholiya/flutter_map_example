import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OpenStreetMap',
        style: TextStyle(
          color: Colors.white,
        ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(0, 0),
                initialZoom: 2,
                minZoom: 0,
                maxZoom: 100,
              ),
              children: [
                TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",),
                CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      child: Icon(Icons.location_pin,
                        color: Colors.white,
                      ),
                    ),
                    markerSize: Size(35, 35),
                    markerDirection: MarkerDirection.heading
                  ),
                )

              ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.my_location,
            size: 30,
            color: Colors.blue,
          ),
          onPressed: (){}),
    );
  }
}
