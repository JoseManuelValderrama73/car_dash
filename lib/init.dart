import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class Init extends StatefulWidget {
  const Init({Key? key}) : super(key: key);

  @override
  State<Init> createState() => _InitState();
}

class _InitState extends State<Init> {
  void setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Permission.locationWhenInUse.status.then((status) {
      if (!mounted) {
        Permission.locationWhenInUse.request();
      }
    });
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('loading icon',
            style: TextStyle(color: CupertinoColors.white)));
  }
}
