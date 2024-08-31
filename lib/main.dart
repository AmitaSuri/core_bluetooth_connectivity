import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bluetooth with RFID '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('samples.flutter.dev/bluetooth');
  static const EventChannel _eventChannel =
  EventChannel('samples.flutter.dev/tag_scanned');
  String _bluetoothStatus = 'Unknown Bluetooth status.';
  List<Map<String,String?>> _availableDevices = [];
  Map<String,String?> _selectedDevice = {};
  bool _loading = false;
  Map<String,String> device ={};
  StreamSubscription<Map<String, dynamic>>? _subscription;

  // Map<String, String> stringMap = originalMap.map((key, value) {
  //   return MapEntry(key.toString(), value.toString());
  // });
  Stream<String> streamTimeFromNative() {
    // const eventChannel = EventChannel('timeHandlerEvent');
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => event.toString());
  }

  Stream<Map<String, dynamic>> get onTagScanned {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<String, dynamic>.from(event));
  }

  //Method to cancel subscription of bluetooth.
  void cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _enableBluetooth() async {
    String status;
    try {
      final bool result = await platform.invokeMethod('enableBluetooth');
      status = result ? 'Bluetooth is enabled' : 'Failed to enable Bluetooth';
    } on PlatformException catch (e) {
      status = "Failed to enable Bluetooth: '${e.message}'.";
    }

    setState(() {
      _bluetoothStatus = status;
    });
  }
  Future<void> handleNativeMethod(MethodCall call) async {
    List<Map<String,String?>> devices =[];
    switch (call.method) {
      case 'onDeviceDiscovered':
        Map<String, String> result = Map<String, String>.from(call.arguments);
        device["name"]=result["name"].toString();
        device["address"]=result["address"].toString();
        // {"name":result?["name"].toString(),"address":result?["address"].toString()};
        print("result:-$device");
        devices.add(device);
        print("resultt:-${device["address"]}");
        print("devices:-$devices");

        setState(() {
          _availableDevices = devices;
          _loading = false;
        });
    }
  }

  Future<void> _getAvailableDevices() async {
    setState(() {
      _loading = true;
    });

    List<Map<String,String?>> devices =[];
    try {
      var result = await platform.invokeMethod('getAvailableDevices');

      // platform.setMethodCallHandler(handleNativeMethod);
      device["name"]=result!["name"].toString();
      device["address"]=result["address"].toString();

      print("result:-$device");
      devices.add(device);
    } on PlatformException catch (e) {
      rethrow;
      // devices = ["Failed to get available devices: '${e.message}'."];
    }

    setState(() {
      _availableDevices = devices;
      _loading = false;
    });
  }

  Future<void> _getPower() async {
    try {
     int value = await platform.invokeMethod('getPower');
     print("getPower:-$value");
    } on PlatformException catch (e) {
      print("Failed to make device discoverable: '${e.message}'.");
    }
  }

  Future<void> _setPower() async {
    try {
     bool value = await platform.invokeMethod('setPower',{"powerLevel":1});
     print("$value");
    } on PlatformException catch (e) {
      print("Failed to make device discoverable: '${e.message}'.");
    }
  }

  Future<void> _connect(Map<String,String?> device) async {
    try {
    bool value =  await platform.invokeMethod('connect',device);
    print(value);
    } on PlatformException catch (e) {
      print("Failed to connect to device: '${e.message}'.");
    }
  }
  Future<void> _disConnect() async {
    try {
    bool value =  await platform.invokeMethod('disConnect');
    print("disConnect:-$value");
    } on PlatformException catch (e) {
      print("Failed to disConnect to device: '${e.message}'.");
    }
  }
  Future<void> _getBatteryLevel() async {
    try {
    int value =  await platform.invokeMethod('getBatteryLevel');
    print("rfid:-$value");
    } on PlatformException catch (e) {
      print("Failed to disConnect to device: '${e.message}'.");
    }
  }

  Future<void> _startScanning() async {
    try {
    var value =  await platform.invokeMethod('startScanning');

    _subscription = onTagScanned.listen((tag) {
       print(tag);
      // handleTagsFromStream(tag);
    });
    print("tagScanned:-$value");
    } on PlatformException catch (e) {
      print("Failed to scan the device: '${e.message}'.");
    }
  }

  Future<void> _stopScanning() async {
    try {
    bool value =  await platform.invokeMethod('stopScanning');
    print("StopScan:-$value");
    } on PlatformException catch (e) {
      print("Failed to stop device: '${e.message}'.");
    }
  }

  Future<void> _clearSeenTags() async {
    try {
    bool value =  await platform.invokeMethod('clearAllTags');
    print("cleanAllTags :-$value");
    } on PlatformException catch (e) {
      print("Failed to stop device: '${e.message}'.");
    }
  }

  Future<void> _clearSingleTags(String epc) async {
    try {
    bool value =  await platform.invokeMethod('clearSingleTag',epc);
    print("cleanAllTags :-$value");
    } on PlatformException catch (e) {
      print("Failed to stop device: '${e.message}'.");
    }
  }

  Future<void> _checkReaderConnectivity() async {
    try {
    bool value =  await platform.invokeMethod('checkReaderConnectivity');
    print("checkReaderConnectivity :-$value");
    } on PlatformException catch (e) {
      print("Failed to stop device: '${e.message}'.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _enableBluetooth,
                child: const Text('Enable Bluetooth'),
              ),
              Text(_bluetoothStatus),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getAvailableDevices,
                child: const Text('Get Available Devices'),
              ),
              ElevatedButton(
                onPressed: _getPower,
                child: const Text('get Power'),
              ),

              ElevatedButton(
                onPressed: _setPower,
                child: const Text('set Power'),
              ),
              ElevatedButton(
                onPressed: _getBatteryLevel,
                child: const Text('Get Battery level'),
              ),
              ElevatedButton(
                onPressed: _disConnect,
                child: const Text('DisConnect'),
              ),
              ElevatedButton(
                onPressed: _startScanning,
                child: const Text('StartScan'),
              ),
              ElevatedButton(
                onPressed: _stopScanning,
                child: const Text('StopScan'),
              ),
              ElevatedButton(
                onPressed: _checkReaderConnectivity,
                child: const Text('check Reader Connectivity'),
              ),
              ElevatedButton(
                onPressed: _clearSeenTags,
                child: const Text('clean all Tags'),
              ),
              // ElevatedButton(
              //   onPressed: _clearAllTags,
              //   child: const Text('clear single Tags'),
              // ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : Column(
                children: _availableDevices
                    .map((device) => ListTile(
                  title: Text(device["name"] as String),
                  onTap: () {
                    setState(() {
                      _selectedDevice = device;
                    });
                    _connect(device);
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              StreamBuilder<String>(
                stream: streamTimeFromNative(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return GestureDetector(
                      onTap: (){
                        _clearSingleTags(RFIDData.fromString("${snapshot.data}").epc);
                        // {epc: 000000000000000000000127, count: 1, rssi: -30.70, user: , tid: }
                      },
                      child: Text(
                        '${snapshot.data}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class RFIDData {
  final String epc;
  final int count;
  final double rssi;
  final String? user;  // Nullable because it might be empty
  final String? tid;   // Nullable because it might be empty

  RFIDData({
    required this.epc,
    required this.count,
    required this.rssi,
    this.user,
    this.tid,
  });

  @override
  String toString() {
    return 'RFIDData(epc: $epc, count: $count, rssi: $rssi, user: ${user ?? "N/A"}, tid: ${tid ?? "N/A"})';
  }

  // Factory method to create an instance from a string
  factory RFIDData.fromString(String data) {
    // Remove the curly braces and split by commas
    final map = Map<String, String>.fromEntries(
        data.substring(1, data.length - 1)  // Remove `{` and `}`
            .split(',')  // Split by comma
            .map((item) {
          final keyValue = item.split(':');
          return MapEntry(keyValue[0].trim(), keyValue[1].trim());
        })
    );

    return RFIDData(
      epc: map['epc']!,
      count: int.parse(map['count']!),
      rssi: double.parse(map['rssi']!),
      user: map['user']?.isNotEmpty == true ? map['user'] : null,
      tid: map['tid']?.isNotEmpty == true ? map['tid'] : null,
    );
  }
}
