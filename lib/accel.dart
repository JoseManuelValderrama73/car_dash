import 'package:car_dash/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Acceleration extends StatefulWidget {
  const Acceleration({ super.key });

  @override
  State<Acceleration> createState() => _AccelerationState();
}

class _AccelerationState extends State<Acceleration> {
  late String unit;
  late int limit;
  int speed = 0;
  bool running = false;
  bool loading = true;
  String finalTimerValue = '';
  
  Future _dtbSetup() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unit = prefs.getStringList('units')![1];
      loading = false;
    });
    if (unit == 'km/h') {
      setState(() {
        limit = 102;
      });
    } else {
      setState(() {
        limit = 62;
      });
    }

  }
  late VideoPlayerController _controller;
  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);

  @override
  void initState() {
    super.initState();
    _dtbSetup();
    if (mounted) {
      _stopWatchTimer.rawTime.listen((value) => setState(() {
            finalTimerValue = StopWatchTimer.getDisplayTime(value, hours: false, minute: false);
      }));
    }
    _controller = VideoPlayerController.asset('assets/stars.mp4');

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize().then((_) => setState(() {}));
    //_controller.play();
  }

  @override
  void dispose() async {
    await _controller.dispose();
    await _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Geolocator.getPositionStream().listen((position) {
      int currentSpeed = 0;
      if (position.speed > 2) {
        if (unit == 'km/h') {
          currentSpeed = (position.speed * 3.6).round();
        } else {
          currentSpeed = ((position.speed * 3.6) / 1.60934).round();
        }
        if (mounted) {
          setState(() {
            running = true;
          });
          _stopWatchTimer.onStartTimer();
          _controller.play();
        }
      } else {
        currentSpeed = 0;
      }
      if (currentSpeed >= limit) {
        if (mounted) {
          setState(() {
            running = false;
          });
          _stopWatchTimer.onStopTimer();
        }
      }
      if (mounted) {
        setState(() {
          speed = currentSpeed;
        });
      }
    });
    return loading ? const Center(child: Loading())
      : Stack(
      children: [
        Visibility(
          visible: running,
          child: VideoPlayer(_controller) 
        ),
        
        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${speed.toString()} $unit', style: const TextStyle(color: CupertinoColors.white, fontSize: 100)),
                Text(finalTimerValue, style: const TextStyle(color: CupertinoColors.white, fontSize: 80))
              ],
            )
          ),
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
}
