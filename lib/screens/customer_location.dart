import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/route_service.dart';
import 'main_screen.dart';

class CustomerLocation extends StatefulWidget {
  final LatLng userLocation;
  final List<LatLng> riderLocations;

  const CustomerLocation({
    super.key,
    required this.userLocation,
    required this.riderLocations,
  });

  @override
  _CustomerLocationState createState() => _CustomerLocationState();
}

class _CustomerLocationState extends State<CustomerLocation> {
  List<Polyline> _polylines = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    List<Polyline> polylines = [];
    for (LatLng riderLocation in widget.riderLocations) {
      final route =
      await RouteService.getRoute(riderLocation, widget.userLocation);
      if (route != null) {
        polylines.add(Polyline(
          points: route,
          strokeWidth: 4.0,
          color: Colors.blue,
        ));
      }
    }
    setState(() {
      _polylines = polylines;
    });
  }

  void _confirmOrderComplete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order Completion'),
          content: const Text('Are you sure you want to mark this order as complete?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order marked as complete!')),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                      (Route<dynamic> route) => false,
                ); // Navigate back to the MainScreen
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.userLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://api.mapbox.com/styles/v1/anexdev/cledzt2qt004h01pcnk0tb5g9/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW5leGRldiIsImEiOiJjbHp6YzZ1ZzQxOHh0Mm1zYW5oNmdhZHRkIn0.EXzK4hcp09SCCv2e0bwXsg',
                userAgentPackageName: 'com.greenhouse.app',
                maxNativeZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: widget.userLocation,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                  ...widget.riderLocations.map((riderLocation) => Marker(
                    width: 80.0,
                    height: 80.0,
                    point: riderLocation,
                    child: const Icon(
                      Icons.motorcycle,
                      color: Colors.blue,
                      size: 40.0,
                    ),
                  )),
                ],
              ),
              PolylineLayer(
                polylines: _polylines,
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _confirmOrderComplete,
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }
}