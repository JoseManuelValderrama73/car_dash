import 'package:flutter/cupertino.dart';
import 'package:car_dash/trips_page/trips_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../loading.dart';

const List _vehicles = [
  'Todos',
  'Coche',
  'Moto',
  'Avión',
  'Trén',
  'Barco',
  'Bicicleta',
  'Andando',
  'Otro'
];

class Trips extends StatefulWidget {
  const Trips({super.key});

  @override
  State<Trips> createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  bool loading = true;
  late IconData icon;
  String? maxSpeed;
  String? avgSpeed;
  String? distance;
  String? time;
  String? vehicle;
  List<String>? units;
  List<String>? tripList;
  List<String>? positionList;
  late SharedPreferences prefs;
  int _selectedVehicle = 0;
  Future getData() async {
    final prefsVar = await SharedPreferences.getInstance();
    setState(() {
      prefs = prefsVar;
      tripList = prefs.getStringList("tripNames");
      units = prefs.getStringList('units');
      loading = false;
    });
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedVehicle == 0) {
      setState((() => icon = CupertinoIcons.line_horizontal_3_decrease_circle));
    } else if (_selectedVehicle == 1) {
      setState((() => icon = CupertinoIcons.car_detailed));
    } else if (_selectedVehicle == 2) {
      setState((() => icon = Icons.motorcycle));
    } else if (_selectedVehicle == 3) {
      setState((() => icon = CupertinoIcons.airplane));
    } else if (_selectedVehicle == 4) {
      setState((() => icon = CupertinoIcons.train_style_one));
    } else if (_selectedVehicle == 5) {
      setState((() => icon = Icons.directions_boat));
    } else if (_selectedVehicle == 6) {
      setState((() => icon = Icons.pedal_bike));
    } else if (_selectedVehicle == 7) {
      setState((() => icon = CupertinoIcons.person));
    } else if (_selectedVehicle == 8) {
      setState((() => icon = Icons.rocket_launch_rounded));
    }
    getData();
    return loading
        ? const Center(child: Loading())
        : SafeArea(
            left: false,
            right: false,
            child: Container(
              color: CupertinoColors.black,
              child: CustomScrollView(
                slivers: [
                  CupertinoSliverNavigationBar(
                    backgroundColor: CupertinoColors.black,
                    trailing: GestureDetector(
                        onTap: () {
                          _showDialog(CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: _selectedVehicle),
                            magnification: 1.22,
                            squeeze: 1.2,
                            useMagnifier: true,
                            itemExtent: 32,
                            onSelectedItemChanged: (int selectedItem) async {
                              setState(() {
                                _selectedVehicle = selectedItem;
                              });
                              // buscar los viajes
                            },
                            children: List<Widget>.generate(_vehicles.length,
                                (int index) {
                              return Center(
                                child: Text(_vehicles[index]),
                              );
                            }),
                          ));
                        },
                        child: Icon(icon)),
                    largeTitle: const Text('Mis viajes',
                        style: TextStyle(color: CupertinoColors.white)),
                  ),
                  SliverFillRemaining(
                      child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tripList!.length,
                    itemBuilder: (context, index) {
                      maxSpeed =
                          prefs.getString('max_speed_${tripList![index]}');
                      avgSpeed =
                          prefs.getString('avg_speed_${tripList![index]}');
                      distance =
                          prefs.getString('distance_${tripList![index]}');
                      time = prefs.getString('time_${tripList![index]}');
                      positionList =
                          prefs.getStringList('location_${tripList![index]}');
                      vehicle = prefs.getString('vehicle_${tripList![index]}');
                      return Visibility(
                        visible: vehicle == _vehicles[_selectedVehicle] ||
                            _selectedVehicle == 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Slidable(
                            direction: Axis.vertical,
                            endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                      backgroundColor: CupertinoColors.black,
                                      foregroundColor:
                                          CupertinoColors.destructiveRed,
                                      icon: CupertinoIcons.delete,
                                      onPressed: (context) async {
                                        tripList!.remove(tripList![index]);
                                        await prefs.setStringList('tripNames',
                                            tripList as List<String>);
                                        prefs.remove(
                                            'max_speed_${tripList![index]}');
                                        prefs.remove(
                                            'avg_speed_${tripList![index]}');
                                        prefs.remove(
                                            'distance_${tripList![index]}');
                                        prefs
                                            .remove('time_${tripList![index]}');
                                        setState(() {});
                                      })
                                ]),
                            child: TripsCard(
                                tripName: tripList![index],
                                maxSpeed: maxSpeed,
                                avgSpeed: avgSpeed,
                                distance: distance,
                                time: time,
                                vehicle: vehicle,
                                units: units,
                                positionList: positionList),
                          ),
                        ),
                      );
                    },
                  ))
                ],
              ),
            ));
  }
}
