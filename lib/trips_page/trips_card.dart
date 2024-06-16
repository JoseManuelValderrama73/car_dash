import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TripsCard extends StatefulWidget {
  const TripsCard(
      {Key? key,
      required this.tripName,
      required this.maxSpeed,
      required this.avgSpeed,
      required this.distance,
      required this.time,
      required this.vehicle,
      required this.units,
      required this.positionList})
      : super(key: key);
  final String? tripName;
  final String? maxSpeed;
  final String? avgSpeed;
  final String? distance;
  final String? time;
  final String? vehicle;
  final List<String>? units;
  final List<String>? positionList;

  @override
  State<TripsCard> createState() => _TripsCardState();
}

class _TripsCardState extends State<TripsCard> {
  late IconData icon;
  @override
  Widget build(BuildContext context) {
    if (widget.vehicle == 'Coche') {
      setState((() => icon = CupertinoIcons.car_detailed));
    } else if (widget.vehicle == 'Moto') {
      setState((() => icon = Icons.motorcycle));
    } else if (widget.vehicle == 'Avión') {
      setState((() => icon = CupertinoIcons.airplane));
    } else if (widget.vehicle == 'Trén') {
      setState((() => icon = CupertinoIcons.train_style_one));
    } else if (widget.vehicle == 'Barco') {
      setState((() => icon = Icons.directions_boat));
    } else if (widget.vehicle == 'Bicicleta') {
      setState((() => icon = Icons.pedal_bike));
    } else if (widget.vehicle == 'Andando') {
      setState((() => icon = CupertinoIcons.person));
    } else if (widget.vehicle == 'Otro') {
      setState((() => icon = Icons.rocket_launch_rounded));
    }
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
          decoration: const BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text('${widget.tripName}',
                  style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(width: 15),
                  Icon(icon, color: CupertinoColors.white)
                ]
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Divider(color: CupertinoColors.lightBackgroundGray),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(widget.time.toString(),
                    style: const TextStyle(
                        color: CupertinoColors.white, fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('Distancia: ${widget.distance} ${widget.units![0]}',
                    style: const TextStyle(
                        color: CupertinoColors.white, fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('Media: ${widget.avgSpeed} ${widget.units![1]}',
                    style: const TextStyle(
                        color: CupertinoColors.white, fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                //child: Text('Máxima: ${widget.maxSpeed} ${widget.units![1]}',
                child: Text('Máxima: ${widget.maxSpeed} ${widget.units![1]}',
                    style: const TextStyle(
                        color: CupertinoColors.white, fontSize: 18)),
              ),
              GestureDetector(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: CupertinoColors.black,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: const Text('Mapa',
                          style: TextStyle(
                              fontSize: 20, color: CupertinoColors.white))),
                  onTap: () => Navigator.pushNamed(context, '/map', arguments: {
                        'positionList': widget.positionList,
                        'tripName': widget.tripName
                      }))
            ]),
          )),
    );
  }
}
