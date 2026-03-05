import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/blocs/race/race_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0, 0), // Equator/Prime Meridian
    zoom: 2.0,
  );

  @override
  void initState() {
    super.initState();
    context.read<RaceBloc>().add(LoadRaces());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa das Corridas')),
      body: BlocBuilder<RaceBloc, RaceState>(
        builder: (context, state) {
          Set<Marker> markers = {};

          if (state is RaceLoaded) {
            for (var race in state.races) {
              if (race.positionLat != 0.0 || race.positionLng != 0.0) {
                markers.add(
                  Marker(
                    markerId: MarkerId(race.id.toString()),
                    position: LatLng(race.positionLat, race.positionLng),
                    infoWindow: InfoWindow(
                      title: race.name,
                      snippet: race.locationTitle,
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                );
              }
            }
          }

          return GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationEnabled: false,
            zoomControlsEnabled: true,
          );
        },
      ),
    );
  }
}
