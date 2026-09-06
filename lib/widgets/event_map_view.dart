import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const EventMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<EventMapView> createState() => _EventMapViewState();
}

class _EventMapViewState extends State<EventMapView> {
  final Completer<GoogleMapController> _controller = Completer();
  late CameraPosition _initialPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    _initialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 15.0,
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('event_location'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.locationName,
          snippet: 'Lokasi Event',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialPosition,
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }
}
