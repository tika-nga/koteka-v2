import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/view_models/filter_view_model.dart';
import 'package:flutter_marketplace_template/view_models/places_model.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/screens/place_screen.dart';
import 'package:flutter_marketplace_template/views/components/filter_buttons.dart';
import 'package:flutter_marketplace_template/views/components/map/map_pin_icon.dart';
import 'package:flutter_marketplace_template/models/place.dart';

/// Screen displaying a Google Map with places as markers
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late PlacesModel _mapViewModel; //callback, to free the user location stream
  late FilterViewModel _filterViewModel;
  late final String? _prevFilterOrderBy;
  late final bool? _prevFilterSortAsc;
  String? _activeMarkerId; //checks which place is currently clicked
  final Map<String, BitmapDescriptor> _smallPlaceIcons = {};
  final Map<String, BitmapDescriptor> _bigPlaceIcons = {};

  bool _isBuildingIcons = false;

  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(51.1079, 17.0385), // Wrocław
    zoom: 12,
  );

  /// Calculates the distance between two points on the Earth's surface
  double _distanceMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;
    final la1 = a.latitude * math.pi / 180;
    final la2 = b.latitude * math.pi / 180;
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * R * math.asin(math.min(1, math.sqrt(h)));
  }

  /// Returns the current radius based on the user's position and the circle
  LatLng _radiusHandlePos(LatLng? userPos, double radiusM) {
    if (userPos == null || radiusM <= 0) {
      return userPos ?? _initialCameraPosition.target;
    }
    final lat = userPos.latitude;
    final lon = userPos.longitude;
    final dLat = 0.0; // going east
    final metersPerDegLon = 111320 * math.cos(lat * math.pi / 180);
    final dLonDeg = radiusM / metersPerDegLon;
    return LatLng(lat + dLat, lon + dLonDeg);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapViewModel = context.read<PlacesModel>();
      _filterViewModel = context.read<FilterViewModel>();
      _prevFilterOrderBy = _filterViewModel.orderBy;
      _prevFilterSortAsc = _filterViewModel.sortAsc;

      _initData();
    });
  }

  /// Helper for building markers, if everything is fine then builds markers
  // Future<void> _ensureMarkersBuild() async {
  //   if (!mounted) return;
  //   if (_mapViewModel.hasErrors) return; // errors in places - abort
  //   if (_mapViewModel.buildingMarkers) return; // already building – do nothing
  //   if (_mapViewModel.places.isEmpty) return; // no data
  //   await _mapViewModel.makeMarkers(context: context); // otherwise create markers
  // }

  /// Resets markers and places and then fetches all places according to current filters
  Future<void> fetchAllPlaces() async {
    _mapViewModel.clearMarkers();
    _mapViewModel.clearPlaces();
    if (_filterViewModel.searchNearbyUser != null) {
      _filterViewModel.setOrderBy('distance');
      _filterViewModel.setSortAsc(true);
    }
    _mapViewModel.abandonFetchingPlaces = false;
    await _mapViewModel.fetchFilteredPlaces(
      buildMarkers: true,
      context: context,
      getAll: true,
    );
    _buildIconsForPlaces(_mapViewModel.places);
  }

  void _setUsermarkerInfoWindow() {
    if (!mounted) return;
    if (_mapViewModel.userMarker != null) {
      _mapViewModel.userMarker = _mapViewModel.userMarker!.copyWith(
        infoWindowParam: InfoWindow(
          title: AppLocalizations.of(context)!.your_location,
        ),
      );
    }
  }

  Future<void> _initData() async {
    // If a fetch is already in progress, subscribe and wait for it to finish
    if (_mapViewModel.isLoading) {
      late VoidCallback sub;
      sub = () async {
        if (!_mapViewModel.isLoading) {
          _mapViewModel.removeListener(sub);
          if (!mounted) return;

          await _mapViewModel.startUserLocationStream();
          await fetchAllPlaces().then((_) => _setUsermarkerInfoWindow());
        }
      };
      _mapViewModel.addListener(sub);
    } else {
      await _mapViewModel.startUserLocationStream();
      await fetchAllPlaces().then((_) => _setUsermarkerInfoWindow());
    }
  }

  /// Builds custom icons for places from their profile pictures
  Future<void> _buildIconsForPlaces(List<Place> places) async {
    if (_isBuildingIcons) return;
    _isBuildingIcons = true;

    int built = 0;

    for (final place in places) {
      if (place.profilePicture.isEmpty) continue;

      if (_smallPlaceIcons.containsKey(place.id)) continue;

      try {
        final smallIcon = await MapPinIconBuilder.buildPinIconFromNetwork(
          imageUrl: place.profilePicture,
          size: 130,
          borderColor: const Color(0xFF10145E),
        );

        final bigIcon = await MapPinIconBuilder.buildPinIconFromNetwork(
          imageUrl: place.profilePicture,
          size: 170,
          borderColor: const Color(0xFF0066FF),
          glowColor: const Color(0x400066FF),
          label: place.name,
        );

        _smallPlaceIcons[place.id] = smallIcon;
        _bigPlaceIcons[place.id] = bigIcon;

        built++;

        if (built % 10 == 0 && mounted) {
          setState(() {});
        }
      } catch (_) {}
    }

    _isBuildingIcons = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mapViewModel.stopUserLocationStream();
    _mapViewModel.stopFetchingPlaces();
    _filterViewModel.setOrderBy(_prevFilterOrderBy, notify: false);
    _filterViewModel.setSortAsc(_prevFilterSortAsc, notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PlacesModel, FilterViewModel>(
      builder: (context, mapViewModel, filterViewModel, child) {
        if (!_isBuildingIcons &&
            mapViewModel.places.isNotEmpty &&
            _smallPlaceIcons.isEmpty) {
          _buildIconsForPlaces(mapViewModel.places);
        }
        // Circle to indicate radius
        final Set<Circle> circles = {};
        var location =
            filterViewModel.searchNearbyUser == true
                ? filterViewModel.userLocation
                : filterViewModel.selectedLocation;
        if (filterViewModel.selectedMaxDistance != null && location != null) {
          circles.add(
            Circle(
              circleId: const CircleId('user-radius'),
              center: location,
              radius: filterViewModel.selectedMaxDistance!.toDouble(), // meters
              fillColor: Colors.blue.withOpacity(0.15),
              strokeColor: Colors.blueAccent,
              strokeWidth: 2,
            ),
          );
        }
        // Used to calculate the position and handle of the radius (cannot change during)
        final radiusM = (filterViewModel.selectedMaxDistance ?? 0).toDouble();

        final markersSnapshot = List<Marker>.from(mapViewModel.markers);
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                markers:
                    {
                      for (final marker in markersSnapshot)
                        marker.copyWith(
                          iconParam: () {
                            final isActive =
                                _activeMarkerId == marker.markerId.value;

                            final small =
                                _smallPlaceIcons[marker.markerId.value];
                            final big = _bigPlaceIcons[marker.markerId.value];

                            if (isActive) {
                              return big ?? small ?? marker.icon;
                            }

                            return small ?? marker.icon;
                          }(),

                          infoWindowParam: const InfoWindow(),

                          onTapParam: () {
                            if (_activeMarkerId == marker.markerId.value) {
                              final index = mapViewModel.places.indexWhere(
                                (p) => p.id == marker.markerId.value,
                              );
                              if (index != -1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PlaceScreen(
                                          place: mapViewModel.places[index],
                                        ),
                                  ),
                                );
                              }
                            } else {
                              setState(() {
                                _activeMarkerId = marker.markerId.value;
                              });
                            }
                          },
                        ),
                      // User marker
                      if (mapViewModel.userMarker != null)
                        mapViewModel.userMarker!,

                      // chosen location marker
                      if (filterViewModel.selectedLocation != null)
                        Marker(
                          markerId: const MarkerId('Custom Location'),
                          position: filterViewModel.selectedLocation!,
                          draggable: true,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                          infoWindow: InfoWindow(
                            title:
                                AppLocalizations.of(context)!.custom_location,
                            snippet:
                                AppLocalizations.of(
                                  context,
                                )!.custom_location_description,
                          ),
                          onDrag: (LatLng pos) {
                            mapViewModel.followUserLocation = false;
                            // Update the center of the circle in real-time
                            filterViewModel.setSelectedLocation(pos);
                          },
                          onDragEnd: (LatLng pos) async {
                            mapViewModel.followUserLocation = false;
                            filterViewModel.setSelectedLocation(pos);
                          },
                        ),

                      // Marker to resize the circle
                      if (location != null && radiusM > 0)
                        Marker(
                          markerId: const MarkerId('CircleRadius'),
                          position: _radiusHandlePos(location, radiusM),
                          draggable: true,
                          icon:
                              mapViewModel.circleResizeIcon ??
                              BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue,
                              ),
                          infoWindow: InfoWindow(
                            title: AppLocalizations.of(context)!.radius,
                            snippet:
    '${((filterViewModel.selectedMaxDistance ?? 0) / 1000).round()} km',
                          ),
                          onDrag: (newPos) {
                            final rawDistance = _distanceMeters(
  location,
  newPos,
).clamp(1000.0, 100000.0);

final newR = <int>[1000, 5000, 10000, 20000, 50000, 100000]
    .reduce(
      (a, b) =>
          (rawDistance - a).abs() < (rawDistance - b).abs()
              ? a
              : b,
    );
filterViewModel.setMaxDistance(newR);
                          },
                          onDragEnd: (newPos) async {
                            final rawDistance = _distanceMeters(
  location,
  newPos,
.clamp(1000, 100000);

final newR = <int>[1000, 5000, 10000, 20000, 50000, 100000]
    .reduce(
      (a, b) =>
          (rawDistance - a).abs() < (rawDistance - b).abs()
              ? a
              : b,
    );

filterViewModel.setMaxDistance(newR);
},
                    }.toSet(),
                circles: circles,
                onMapCreated: (controller) {
                  _mapController = controller;
                  mapViewModel.onUserLocationChanged = (LatLng newPosition) {
                    _mapController.animateCamera(
                      CameraUpdate.newLatLng(newPosition),
                    );
                  };
                },
                // Reset active marker when tapping anywhere else on the map
                onTap: (LatLng position) {
                  if (_activeMarkerId != null) {
                    setState(() {
                      _activeMarkerId = null;
                    });
                  }
                },
              ),
              // Filter and reset buttons
              Positioned(
                top: 16,
                left: 38,
                right: 38,
                child: SafeArea(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        // Buttons use helpers in views/components/filter_buttons.dart
                        filterButton(
                          context,
                          MediaQuery.of(context).size.width / 400,
                        ),
                        const SizedBox(width: 8),
                        resetFilterButton(
                          context,
                          MediaQuery.of(context).size.width / 400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Loader above the map
              if (mapViewModel.isLoading)
                Positioned(
                  top: 32,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),

              // Small loader in the corner only for building markers
              if (!mapViewModel.isLoading && mapViewModel.buildingMarkers)
                Positioned(
                  top: 90,
                  right: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              // Error handling
              if (mapViewModel.hasErrors)
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.failed_to_load_map,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // *** Side buttons ***
          //
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User location button
              FloatingActionButton(
                heroTag: 'fab_location',
                tooltip: 'My location',
                backgroundColor: Colors.yellow,
                onPressed: () async {
                  mapViewModel.followUserLocation = true;
                  setState(() => _activeMarkerId = null);
                  if (mapViewModel.positionStream == null) {
                    await mapViewModel.startUserLocationStream();
                  }
                  await mapViewModel.updateUserMarker();
                  if (mapViewModel.userMarker == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.unable_to_get_location,
                        ),
                      ),
                    );
                    mapViewModel.followUserLocation = false;
                    return;
                  }
                  filterViewModel.setSearchNearbyUser(true);
                  if (mapViewModel.userMarker != null) {
                    _mapController.animateCamera(
                      CameraUpdate.newLatLng(mapViewModel.userMarker!.position),
                    );
                  }
                },
                child: const Icon(Icons.my_location),
              ),

              // Selected location button
              if (filterViewModel.selectedLocation != null) ...[
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'fab_selected_location',
                  tooltip: 'Selected location',
                  backgroundColor: Colors.green,
                  onPressed: () {
                    final loc = filterViewModel.selectedLocation;
                    if (loc == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.no_selected_location,
                          ),
                        ),
                      );
                      return;
                    }
                    filterViewModel.setSearchNearbyUser(false);
                    setState(() => _activeMarkerId = null);
                    _mapController.animateCamera(CameraUpdate.newLatLng(loc));
                  },
                  child: const Icon(Icons.place),
                ),
              ],
              const SizedBox(height: 12),

              // Refresh button
              FloatingActionButton(
                heroTag: 'fab_refresh',
                tooltip: 'Refresh places',
                onPressed: () async {
                  await fetchAllPlaces();
                },
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
        );
      },
    );
  }
}
