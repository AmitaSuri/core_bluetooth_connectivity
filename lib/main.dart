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
  String _bluetoothStatus = 'Unknown Bluetooth status.';
  List<Map<String,String?>> _availableDevices = [];
  Map<String,String?> _selectedDevice = {};
  bool _loading = false;
  Map<String,String> device ={};
  // Map<String, String> stringMap = originalMap.map((key, value) {
  //   return MapEntry(key.toString(), value.toString());
  // });

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

  Future<void> _getAvailableDevices() async {
    setState(() {
      _loading = true;
    });

    List<Map<String,String?>> devices =[];
    try {
      var result = await platform.invokeMethod('getAvailableDevices');
      device["name"]=result!["name"].toString();
      device["address"]=result["address"].toString();
      // {"name":result?["name"].toString(),"address":result?["address"].toString()};
      print("result:-$device");
      devices.add(device);
      print("resultt:-${device["address"]}");
      // _selectedDevice = result["address"];
      // devices = result.cast<String>().;
    } on PlatformException catch (e) {
      rethrow;
      // devices = ["Failed to get available devices: '${e.message}'."];
    }

    setState(() {
      _availableDevices = devices;
      _loading = false;
    });
  }

  // Future<void> _startBluetoothDiscovery() async {
  //   try {
  //     await platform.invokeMethod('startBluetoothDiscovery');
  //     // Call _getAvailableDevices after starting discovery to refresh the list
  //     await _getAvailableDevices();
  //   } on PlatformException catch (e) {
  //     print("Failed to start Bluetooth discovery: '${e.message}'.");
  //   }
  // }


  Future<void> _getPower() async {
    try {
      await platform.invokeMethod('getPower');
    } on PlatformException catch (e) {
      print("Failed to make device discoverable: '${e.message}'.");
    }
  }
  Future<void> _setPower() async {
    try {
      await platform.invokeMethod('setPower',{"powerLevel":1});
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setPower,
                child: const Text('set Power'),
              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
