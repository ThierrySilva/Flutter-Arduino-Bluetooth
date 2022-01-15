// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:layout/ListaBluetooth.dart';
import 'package:layout/HomePage.dart';
import 'package:layout/provider/StatusConexaoProvider.dart';
import 'package:provider/provider.dart';
import 'components/CustomAppBar.dart';

class SelecionarDispositivoPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SelecionarDispositivoPage({this.checkAvailability = true});

  @override
  _SelecionarDispositivoPage createState() => _SelecionarDispositivoPage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice? device;
  _DeviceAvailability? availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi])
      : super(address: device!.address);
}

class _SelecionarDispositivoPage extends State<SelecionarDispositivoPage> {
  List<_DeviceWithAvailability> devices = <_DeviceWithAvailability>[];

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool? _isDiscovering;

  _SelecionarDispositivoPage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering!) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription!.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ListaBluetoothPage> list = devices
        .map(
          (_device) => ListaBluetoothPage(
            device: _device.device,
            onTap: () {
              Provider.of<StatusConexaoProvider>(context, listen: false)
                  .setDevice(_device.device!);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  settings: const RouteSettings(name: '/'),
                  builder: (context) => HomePage()));
            },
          ),
        )
        .toList();
    return Scaffold(
      appBar: CustomAppBar(
        Title: 'Bluetooh list',
        isBluetooth: false,
        isDiscovering: false,
        onPress: () {},
      ),
      body: ListView(
        children: list,
      ),
    );
  }
}
