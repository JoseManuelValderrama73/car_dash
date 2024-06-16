import 'dart:ui';

import 'package:car_dash/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pro extends StatefulWidget {
  const Pro({Key? key, required this.tripName}) : super(key: key);
  final String? tripName;

  @override
  State<Pro> createState() => _ProState();
}

class _ProState extends State<Pro> {
  late SharedPreferences prefs;
  bool loading = true;
  Future getData() async {
    final prefsVar = await SharedPreferences.getInstance();
    setState(() {
      prefs = prefsVar;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return loading
        ? const Center(child: Loading())
        : Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage('assets/apple_park.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(0.0)),
                  ),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Versión PRO',
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                const Text(
                    'Para poder acceder a un mapa de la ruta, debes mejorar a la versión PRO',
                    style: TextStyle(
                        fontFamily: 'ComicSans',
                        color: CupertinoColors.white,
                        fontSize: 20)),
                CupertinoButton(
                    child: const Text('Mejorar'),
                    onPressed: () async {
                      await prefs.setBool('pro', true);
                      setState(() {});
                    })
              ]),
            ],
          );
  }
}
