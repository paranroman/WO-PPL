import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;

  // Default misalnya Medan
  static const LatLng _defaultLatLng = LatLng(3.5952, 98.6722);
  LatLng? _selectedLatLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pilih Lokasi Event",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_selectedLatLng != null) {
                Navigator.of(context).pop(_selectedLatLng);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Silakan pilih lokasi terlebih dahulu"),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultLatLng,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: (latLng) {
          setState(() {
            _selectedLatLng = latLng;
          });
        },
        markers: _selectedLatLng == null
            ? {}
            : {
          Marker(
            markerId: const MarkerId('selected'),
            position: _selectedLatLng!,
          ),
        },
      ),
    );
  }
}
