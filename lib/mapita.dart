import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geovisor/infoLatLong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapita extends StatefulWidget {
  const Mapita({super.key});

  @override
  State<StatefulWidget> createState() => _MapitaState();
}

class _MapitaState extends State<Mapita> {
  String latitud = "";
  String longitud = "";
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kUniversidad = CameraPosition(
    target: LatLng(21.881715418726223, -102.30074117088638),
    zoom: 17,
  );

  static const CameraPosition _kInegi = CameraPosition(
    target: LatLng(21.857203725938653, -102.28347478635189),
    zoom: 17,
  );

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('universidad'),
      position: LatLng(21.881715418726223, -102.30074117088638),
      infoWindow:
          InfoWindow(title: 'Universidad de la Ciudad de Aguascalientes'),
    ),
    const Marker(
      markerId: MarkerId('inegi'),
      position: LatLng(21.857203725938653, -102.28347478635189),
      infoWindow:
          InfoWindow(title: 'Instituto Nacional de Estadística y Geografía'),
    )
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Geovisor"),
      ),
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: GoogleMap(
              onTap: _onMapTapped,
              mapType: MapType.hybrid,
              initialCameraPosition: _kUniversidad,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[200],
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            InfoLatLong(Latitude: latitud, Longitude: longitud),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _goToUniversity,
                            child: const Text('Ir a la Universidad'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _goToINEGI,
                            child: const Text('Ir al INEGI'),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para centrar el mapa en la posición de la Universidad
  Future<void> _goToUniversity() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kUniversidad));
  }

  // Función para centrar el mapa en la posición del INEGI
  Future<void> _goToINEGI() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kInegi));
  }

  Future<void> _gotoLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(double.tryParse(latitud)!, double.tryParse(longitud)!),
          zoom: 20,
        ),
      ),
    );
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _markers
          .removeWhere((marker) => marker.markerId.value == 'tapped_location');

      _markers.add(
        Marker(
          markerId: const MarkerId('tapped_location'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Localización Seleccionada.'),
        ),
      );

      latitud = latLng.latitude.toString();
      longitud = latLng.longitude.toString();

      _gotoLocation();
    });
  }
}
