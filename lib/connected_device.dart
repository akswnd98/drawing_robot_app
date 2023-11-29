import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectedDevice {
  static final ConnectedDevice _instance =
      ConnectedDevice._privateConstructor();
  factory ConnectedDevice() {
    return _instance;
  }
  ConnectedDevice._privateConstructor();
  static BluetoothDevice? _device;
  void setDevice(BluetoothDevice device) {
    _device = device;
  }

  BluetoothDevice getDevice() {
    if (_device == null) {
      throw Exception('no connected device');
    }
    return _device!;
  }
}
