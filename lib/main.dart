import 'package:flutter/cupertino.dart';
import 'package:car_dash/init.dart';
import 'package:car_dash/home.dart';
import 'package:car_dash/accel.dart';
import 'package:car_dash/trips_page/trips.dart';
import 'package:car_dash/trips_page/fullscreen_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(title: 'Car Dash', initialRoute: '/', routes: {
      '/': (context) => const Init(),
      '/home': (context) => const Home(),
      '/trips': (context) => const Trips(),
      '/accel': (context) => const Acceleration(),
      '/map': (context) => const FSMap()
    });
  }
}
