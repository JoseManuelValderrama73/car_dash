import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/cupertino.dart';
import 'package:car_dash/loading.dart';

class Compass extends StatefulWidget {
  const Compass({Key? key}) : super(key: key);

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  CompassEvent? data;
  int point = 0;

  Future getDegrees() async {
    data = await FlutterCompass.events!.first;
    setState(() {
      point = double.parse((data!.heading).toString()).round();
      point -= 90;
    });
  }

  @override
  Widget build(BuildContext context) {
    getDegrees();
    return Column(
      children: <Widget>[
        _buildManualReader(),
        _buildCompass(),
      ],
    );
  }

  Widget _buildManualReader() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: Text('$pointº',
            style: const TextStyle(
                color: CupertinoColors.systemGrey, fontSize: 10)));
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Loading(),
            ),
          );
        }

        // if direction is null, then device does not support this sensor
        // show error message

        return Padding(
          padding: const EdgeInsets.all(5),
          child: Transform.rotate(
              angle: (((135 + point) * math.pi) / 180),
              child: const Icon(CupertinoIcons.compass,
                  color: CupertinoColors.white)),
        );
      },
    );
  }
}
