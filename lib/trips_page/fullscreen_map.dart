import 'package:car_dash/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:car_dash/pro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FSMap extends StatefulWidget {
  const FSMap({Key? key}) : super(key: key);

  @override
  State<FSMap> createState() => _FSMapState();
}

class _FSMapState extends State<FSMap> {
  GoogleMapController? mapController;
  Map data = {};
  List<LatLng> positionList = [];
  bool loading = true;
  late bool? pro;

  Future getData(Map dataList) async {
    List<LatLng> positionListVar = [];
    final prefs = await SharedPreferences.getInstance();
    
    
    
    for (int i = 0; i < dataList['positionList'].length; i += 2) {
      positionListVar.add(LatLng(double.parse(dataList['positionList'][i]),
          double.parse(dataList['positionList'][i + 1])));
    }
    
    setState(() {
      if (prefs.getBool('pro') == null) {
        prefs.setBool('pro', false);
        pro = false;
      } else {
        pro = prefs.getBool('pro');
      }
      positionList = positionListVar;
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
    getData(data);    
    return loading
        ? const Center(child: Loading())
        : Stack(
            children: [
              pro!
                  ? GoogleMap(
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      trafficEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: positionList[0],
                        zoom: 17,
                      ),
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('line'),
                          points: positionList,
                          color: CupertinoColors.activeBlue,
                        )
                      },
                      markers: {
                        Marker(
                            markerId: const MarkerId('start'),
                            position: positionList[0],
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen)),
                        Marker(
                            markerId: const MarkerId('finish'),
                            position: positionList[positionList.length - 1]),
                      },
                      onMapCreated: onMapCreated,
                      onCameraMove: null,
                    )
                  : Pro(tripName: data['tripName']),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CupertinoColors.black,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(CupertinoIcons.back,
                                color: CupertinoColors.white, size: 40),
                          )),
                      onTap: () => Navigator.pop(context)),
                ),
              ),
            ],
          );
  }

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
