import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Map extends StatefulWidget {
  const Map({Key? key, required this.position}) : super(key: key);
  final Position? position;

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController? mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mapController?.moveCamera(CameraUpdate.newLatLng(
        LatLng(widget.position!.latitude, widget.position!.longitude)));
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationEnabled: true,
      trafficEnabled: true,
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.position!.latitude, widget.position!.longitude),
        zoom: 17,
      ),
      onMapCreated: onMapCreated,
      onCameraMove: null,
    );
  }

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
