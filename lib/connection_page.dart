import 'package:drawing_robot_app/connected_device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ConnectionPageState();
}

class ConnectionPageState extends State<ConnectionPage> {
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    FlutterBluePlus.scanResults.listen((results) async {
      scanResults = results;
      setState(() {});
    });
    (() async {
      await FlutterBluePlus.startScan(
        timeout: const Duration(minutes: 5),
      );
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bluetooth scan'),
      ),
      body: ListView.builder(
        itemCount: scanResults.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              scanResults[index].device.platformName ?? 'Unknown Device',
            ),
            subtitle: Text(scanResults[index].device.remoteId.toString()),
            onTap: () async {
              try {
                await scanResults[index].device.connect();
                ConnectedDevice().setDevice(scanResults[index].device);
                Fluttertoast.showToast(
                  msg:
                      '${ConnectedDevice().getDevice().platformName} ${ConnectedDevice().getDevice().remoteId} 와 연결 되었습니다.',
                );
              } catch (e) {
                print(e.toString());
                Fluttertoast.showToast(msg: e.toString());
              }
            },
          );
        },
      ),
    );
  }
}
