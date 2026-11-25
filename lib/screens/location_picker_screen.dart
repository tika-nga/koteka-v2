
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialLocation,
  });

  final LatLng? initialLocation;

  @override
  State<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();

  // Centre initial : Kinshasa.
  static const LatLng _kinshasa = LatLng(-4.325, 15.322);

  late LatLng _selectedLocation;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? _kinshasa;
  }

  Future<void> _useGps() async {
    setState(() => _loadingGps = true);

    try {
      final enabled =
          await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        throw Exception(
          'Activez la localisation de votre téléphone.',
        );
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Autorisation de localisation refusée.',
        );
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() => _selectedLocation = location);
      _mapController.move(location, 16);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingGps = false);
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation de l’annonce'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _selectedLocation = camera.center;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mpitsol.randki',
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          // Repère fixe au centre de la carte.
          const Center(
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 48,
              ),
            ),
          ),

          Positioned(
            right: 16,
            top: 16,
            child: FloatingActionButton.small(
              heroTag: 'location_gps',
              onPressed: _loadingGps ? null : _useGps,
              child: _loadingGps
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    _selectedLocation,
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text(
                  'Confirmer cet emplacement',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
