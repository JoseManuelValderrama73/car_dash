import 'package:flutter/cupertino.dart';
import 'package:car_dash/widgets/map.dart';
import 'package:car_dash/widgets/compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import '../loading.dart';

const List _units = [
  ['km', 'km/h'],
  ['mi', 'mph'],
];

const List _vehicles = [
  '-',
  'Coche',
  'Moto',
  'Avión',
  'Trén',
  'Barco',
  'Bicicleta',
  'Andando',
  'Otro'
];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late SharedPreferences prefs;
  bool _loading = true;
  Position? sourceLocation;
  List<String> positionList = [];
  int i = 0;
  int speed = 0;
  bool running = false;
  bool paused = false;
  int maxSpeed = 0;
  num average = 0;
  num distance = 0;
  String finalTimerValue = '';
  int rawSeconds = 0;
  List<int> speedList = [];
  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);
  int _selectedUnit = 0;
  int _selectedVehicle = 0;
  DateTime date = DateTime.now();
  late String tripName = '${date.day}/${date.month}/${date.year}';

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.rawTime.listen((value) => setState(() {
          finalTimerValue = StopWatchTimer.getDisplayTime(value);
          rawSeconds = StopWatchTimer.getRawSecond(value);
        }));
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  void endTrip(List<String>? tripNames, String tripName) async {
    if (tripNames == null) {
      List<String>? tripNames = [tripName];
      await prefs.setStringList('tripNames', tripNames);
    } else {
      tripNames.add(tripName);
      await prefs.setStringList('tripNames', tripNames);
    }
    await prefs.setString('max_speed_$tripName', maxSpeed.toString());
    await prefs.setString('avg_speed_$tripName', average.toString());
    await prefs.setString('distance_$tripName', distance.toString());
    await prefs.setString('time_$tripName', finalTimerValue.toString());
    await prefs.setStringList('location_$tripName', positionList);
    _stopWatchTimer.onResetTimer();
    setState(() {
      speed = 0;
      average = 0;
      maxSpeed = 0;
      paused = false;
      speedList = [];
      positionList = [];
      _selectedVehicle = 0;
      _selectedVehicle = 0;
    });
  }

  Future _determinePosition() async {
    Position? location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _loading = false;
      sourceLocation = location;
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

  void _showSettingsAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('No se pueden modificar los ajustes durante la ruta'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('0K'),
          ),
        ],
      ),
    );
  }

  /* void _showNewTripAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('¿Desea guardar la ruta?'),
        content: Column(children: [
          const SizedBox(height: 15),
          CupertinoTextField(
            controller: textFieldController,
            onEditingComplete: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
          GestureDetector(
              onTap: () {
                if (textFieldController.text.isEmpty) {
                  showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('Ponga un nombre a la ruta'),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('0K'),
                            ),
                          ],
                        );
                      });
                } else {
                  _showDialog(CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 32,
                    onSelectedItemChanged: (int selectedItem) async {
                      setState(() {
                        _selectedVehicle = selectedItem;
                      });
                      await prefs.setString(
                          'vehicle_${textFieldController.text}',
                          _vehicles[_selectedVehicle]);
                    },
                    children:
                        List<Widget>.generate(_vehicles.length, (int index) {
                      return Center(
                        child: Text(_vehicles[index]),
                      );
                    }),
                  ));
                }
              },
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                          width: 2, color: CupertinoColors.activeBlue)),
                  margin: const EdgeInsets.all(20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  child:
                      const Text('Vehículo', style: TextStyle(fontSize: 20))))
        ]),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              textFieldController.text = '';
              showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text('¿Desea eliminar la ruta?'),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            _stopWatchTimer.onResetTimer();
                            setState(() {
                              speed = 0;
                              average = 0;
                              maxSpeed = 0;
                              paused = false;
                              speedList = [];
                              positionList = [];
                              _selectedVehicle = 0;
                              _selectedVehicle = 0;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Eliminar'),
                        ),
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                      ],
                    );
                  });
            },
            child: const Text('Eliminar'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (textFieldController.text.isNotEmpty) {
                List<String>? tripNames = prefs.getStringList('tripNames');
                if (tripNames != null) {
                  if (_selectedVehicle == 0) {
                    showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text('Seleccione un vehículo'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('0K'),
                              ),
                            ],
                          );
                        });
                  } else {
                    if (tripNames.contains(textFieldController.text)) {
                      showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text(
                                  'Ya existe una ruta con ese nombre'),
                              content: const Text(
                                  'Cambie el nombre para que se pueda guardar'),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('0K'),
                                ),
                              ],
                            );
                          });
                    } else {
                      endTrip(tripNames);
                      Navigator.pop(context);
                    }
                  }
                } else {
                  endTrip(tripNames);
                  Navigator.pop(context);
                }
              } else {
                showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text('Ponga un nombre a la ruta'),
                        actions: <CupertinoDialogAction>[
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('0K'),
                          ),
                        ],
                      );
                    });
              }
              textFieldController.text = '';
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  } */
  
  void _showNewTripAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('¿Desea guardar la ruta?'),
        content: Column(children: [
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
                _showDialog(CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  onSelectedItemChanged: (int selectedItem) async {
                    setState(() {
                      _selectedVehicle = selectedItem;
                    });
                    await prefs.setString(
                        'vehicle_$tripName',
                        _vehicles[_selectedVehicle]);
                  },
                  children:
                      List<Widget>.generate(_vehicles.length, (int index) {
                    return Center(
                      child: Text(_vehicles[index]),
                    );
                  }),
                ));
            },
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                          width: 2, color: CupertinoColors.activeBlue)),
                  margin: const EdgeInsets.all(20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  child:
                      const Text('Vehículo', style: TextStyle(fontSize: 20))))
        ]),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text('¿Desea eliminar la ruta?'),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            _stopWatchTimer.onResetTimer();
                            setState(() {
                              speed = 0;
                              average = 0;
                              maxSpeed = 0;
                              paused = false;
                              speedList = [];
                              positionList = [];
                              _selectedVehicle = 0;
                              _selectedVehicle = 0;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Eliminar'),
                        ),
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancelar'),
                        ),
                      ],
                    );
                  });
            },
            child: const Text('Eliminar'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
                List<String>? tripNames = prefs.getStringList('tripNames');
                if (tripNames != null) {
                  if (_selectedVehicle == 0) {
                    showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text('Seleccione un vehículo'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                isDefaultAction: true,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('0K'),
                              ),
                            ],
                          );
                        });
                  } else {
                      endTrip(tripNames, tripName);
                      Navigator.pop(context);
                  }
                } else {
                  endTrip(tripNames, tripName);
                  Navigator.pop(context);
                }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future _dtbSetup() async {
    final getPrefs = await SharedPreferences.getInstance();
    setState(() => prefs = getPrefs);
    // units
    List<String>? unitsFromDTB = prefs.getStringList('units');
    if (unitsFromDTB == null) {
      await prefs.setStringList('units', <String>[
        _units[_selectedUnit][0],
        _units[_selectedUnit][1],
      ]);
    } else {
      if (unitsFromDTB[0] == 'km') {
        setState(() => _selectedUnit = 0);
      } else {
        _selectedUnit = 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _dtbSetup();
    _determinePosition();
    if (running) {
      i += 1;
      Geolocator.getPositionStream().listen((position) {
        if (position.speed > 2) {
          setState(() => paused = false);

          if (_selectedUnit == 0) {
            setState(() => speed = (position.speed * 3.6).round());
          } else {
            setState(() => speed = ((position.speed * 3.6) / 1.60934).round());
          }
        } else {
          setState(() => speed = 0);
        }
      });
      if (i == 120) {
        if (!paused) {
          speedList.add(speed);
          positionList.add(
            sourceLocation!.latitude.toString(),
          );
          positionList.add(sourceLocation!.longitude.toString());
        }
        i = 0;
      }
      if (speedList.isNotEmpty) {
        for (var element in speedList) {
          average += element;
        }
        average /= speedList.length;
        average = average.round();
      }
      if (speed > maxSpeed) {
        setState(() => maxSpeed = speed);
      }
      if (speed < 2) {
        _stopWatchTimer.onStopTimer();
        setState(() => paused = true);
      }
      distance = (average * (rawSeconds / 3600)).round();
    }
    return _loading
        ? const Loading()
        : SafeArea(
            child: CupertinoPageScaffold(
                backgroundColor: CupertinoColors.black,
                child: Row(children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                color: CupertinoColors
                                                    .darkBackgroundGray,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15))),
                                            child: SizedBox.expand(
                                              child: FittedBox(
                                                fit: BoxFit.fitHeight,
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Text(finalTimerValue,
                                                        style: const TextStyle(
                                                            color:
                                                                CupertinoColors
                                                                    .white)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 4,
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: CupertinoColors
                                                      .darkBackgroundGray,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15))),
                                              child: SizedBox.expand(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: !paused ? Text(
                                                          running
                                                              ? '$speed ${_units[_selectedUnit][1]}'
                                                              : '-',
                                                          style: const TextStyle(
                                                              color:
                                                                  CupertinoColors
                                                                      .white))
                                                          : CupertinoButton(
                                                            onPressed: () => Navigator.pushNamed(context, '/accel'),
                                                            child: const Text('Aceleración')
                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ))),
                                    Expanded(
                                        flex: 3,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      color: CupertinoColors
                                                          .darkBackgroundGray,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15))),
                                                  child: SizedBox.expand(
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Column(
                                                            children: [
                                                              const Text(
                                                                  'Media',
                                                                  style: TextStyle(
                                                                      color: CupertinoColors
                                                                          .systemGrey,
                                                                      fontSize:
                                                                          12)),
                                                              Text(
                                                                  running
                                                                      ? '$average ${_units[_selectedUnit][1]}'
                                                                      : '-',
                                                                  style: const TextStyle(
                                                                      color: CupertinoColors
                                                                          .white)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      color: CupertinoColors
                                                          .darkBackgroundGray,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15))),
                                                  child: SizedBox.expand(
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          child: Column(
                                                            children: [
                                                              const Text(
                                                                  'Máxima',
                                                                  style: TextStyle(
                                                                      color: CupertinoColors
                                                                          .systemGrey,
                                                                      fontSize:
                                                                          12)),
                                                              Text(
                                                                  running
                                                                      ? '$maxSpeed ${_units[_selectedUnit][1]}'
                                                                      : '-',
                                                                  style: const TextStyle(
                                                                      color: CupertinoColors
                                                                          .white)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: CupertinoColors
                                                  .darkBackgroundGray,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          child: SizedBox.expand(
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Column(
                                                    children: [
                                                      const Text('Distancia',
                                                          style: TextStyle(
                                                              color:
                                                                  CupertinoColors
                                                                      .systemGrey,
                                                              fontSize: 10)),
                                                      Text(
                                                          running
                                                              ? '$distance ${_units[_selectedUnit][0]}'
                                                              : '-',
                                                          style: const TextStyle(
                                                              color:
                                                                  CupertinoColors
                                                                      .white)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                            decoration: const BoxDecoration(
                                                color: CupertinoColors
                                                    .darkBackgroundGray,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15))),
                                            child: const SizedBox.expand(
                                              child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child:
                                                      Center(child: Compass())),
                                            )),
                                      )),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(children: [
                            Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: running
                                            ? CupertinoColors.destructiveRed
                                            : CupertinoColors.activeGreen,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (running) {
                                          _stopWatchTimer.onStopTimer();
                                          _showNewTripAlertDialog(context);
                                        } else {
                                          _stopWatchTimer.onStartTimer();
                                          setState(() => paused = false);
                                        }
                                        setState(() {
                                          running = !running;
                                        });
                                      },
                                      child: SizedBox.expand(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                  running
                                                      ? 'Finalizar'
                                                      : 'Iniciar',
                                                  style: const TextStyle(
                                                      color: CupertinoColors
                                                          .white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: paused
                                            ? CupertinoColors.activeOrange
                                            : CupertinoColors
                                                .darkBackgroundGray,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15))),
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        if (running) {
                                          paused
                                              ? _stopWatchTimer.onStartTimer()
                                              : _stopWatchTimer.onStopTimer();
                                          setState(() {
                                            paused = !paused;
                                          });
                                        }
                                      }),
                                      child: SizedBox.expand(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                  paused
                                                      ? 'Reanudar'
                                                      : 'Pausar',
                                                  style: TextStyle(
                                                      color: paused
                                                          ? CupertinoColors
                                                              .white
                                                          : CupertinoColors
                                                              .activeOrange)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color:
                                            CupertinoColors.darkBackgroundGray,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!running) {
                                          _showDialog(
                                            CupertinoPicker(
                                              scrollController:
                                                  FixedExtentScrollController(
                                                      initialItem:
                                                          _selectedUnit),
                                              magnification: 1.22,
                                              squeeze: 1.2,
                                              useMagnifier: true,
                                              itemExtent: 32,
                                              onSelectedItemChanged:
                                                  (int selectedItem) async {
                                                setState(() {
                                                  _selectedUnit = selectedItem;
                                                });
                                                await prefs.setStringList(
                                                    'units', <String>[
                                                  _units[_selectedUnit][0],
                                                  _units[_selectedUnit][1],
                                                ]);
                                              },
                                              children: List<Widget>.generate(
                                                  _units.length, (int index) {
                                                return Center(
                                                  child: Text(
                                                    '${_units[index][0]} - ${_units[index][1]}',
                                                  ),
                                                );
                                              }),
                                            ),
                                          );
                                        } else {
                                          _showSettingsAlertDialog(context);
                                        }
                                      },
                                      child: const SizedBox.expand(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                  CupertinoIcons.settings,
                                                  color: CupertinoColors
                                                      .systemGrey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color:
                                            CupertinoColors.darkBackgroundGray,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/trips');
                                      },
                                      child: const SizedBox.expand(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                  CupertinoIcons
                                                      .square_stack_3d_down_right,
                                                  color: CupertinoColors
                                                      .systemGrey),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                          ]),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Map(position: sourceLocation),
                            ),
                          ),
                        ),
                      )),
                ])),
          );
  }
}
