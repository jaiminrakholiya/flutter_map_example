import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (!await _checktheRequestPermissions()) return;

    /// Listen for location updates and update the current location
    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          isLoading = false;
        });
      }
    });
  }

  /// Method to fetch coordinates for a given location using OpenStreetMap Nominatim API
  Future<void> fetchCoordinatesPoint(String location) async {
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        /// Extract latitude and longitude from the API response.
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _destination = LatLng(lat, lon);
        });
        await fetchRoute();
      } else {
        errorMessage('Location not found. Please try another search.');
      }
    } else {
      errorMessage('Failed to fetch location. Try again later.');
    }
  }

  /// Method to fetch the route between the current location and the destination using the OSRM API.
  Future<void> fetchRoute() async {
    if (_currentLocation == null || _destination == null) return;

    final url = Uri.parse(
        "http://router.project-osrm.org/route/v1/driving/"
            "${_currentLocation!.longitude},${_currentLocation!.latitude};"
            "${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    } else {
      errorMessage('Failed to fetch route. Try again later.');
    }
  }

  /// Method to decode the polyline received from OSRM API
  void _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result = polylinePoints.decodePolyline(encodedPolyline);

    setState(() {
      _route = result.map((point) => LatLng(point.latitude, point.longitude)).toList();
    });
  }

  Future<bool> _checktheRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    /// Check if location permissions are granted
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Current location not available.")),
      );
    }
  }

  /// Method to display an error message using a SnackBar.
  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OpenStreetMap',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          isLoading ? Center(child: const CircularProgressIndicator())
          : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(0, 0),
              initialZoom: 2,
              minZoom: 0,
              maxZoom: 100,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              if(_destination != null)
                MarkerLayer(
                    markers:[
                      Marker(
                        width: 50,
                        height: 50,
                        point: _destination!,
                        child: Icon(
                            Icons.location_pin,
                          color: Colors.red,
                        ),
                      )
                    ]
                ),
              if(_currentLocation != null && _destination != null && _route.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(points: _route,strokeWidth: 5,color: Colors.red,),
                ])
            ],
          ),
          Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    /// Expanded widget to make the text field take up available space.
                    Expanded(
                        child:TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter a location',
                            border: OutlineInputBorder(
                              borderRadius:
                                BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                    ),
                    /// IconButton to trigger the search for the entered location.
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: (){
                          final location = _locationController.text.trim();
                          if(location.isNotEmpty){
                            fetchCoordinatesPoint(
                              location
                            );
                          }
                        },
                        icon: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _userCurrentLocation,
        child: Icon(
          Icons.my_location,
          size: 30,
          color: Colors.blue,
        ),
      ),
    );
  }
}
