import CoreBluetooth
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
    var intractor:BluetoothInteractor = BluetoothInteractor()
    private var centralManager: CBCentralManager!
    private var discoveredDevices: [CBPeripheral] = []
    private var flutterResult: FlutterResult?
    private var eventChannel: FlutterEventChannel?
    var streamHandler = MyStreamHandler()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller = window?.rootViewController as! FlutterViewController
        let bluetoothChannel = FlutterMethodChannel(name: "samples.flutter.dev/bluetooth",
                                                    binaryMessenger: controller.binaryMessenger)
        eventChannel = FlutterEventChannel(name: "samples.flutter.dev/tag_scanned", binaryMessenger: controller.binaryMessenger)
            eventChannel?.setStreamHandler(streamHandler)
        
        bluetoothChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            switch call.method {
            case "enableBluetooth":
                self.enableBluetooth(result: result)
            case "getAvailableDevices":
                self.getAvailableDevices { res in
                    switch res {
                    case .success(let device):
                        result(device)
//                        bluetoothChannel.invokeMethod("onDeviceDiscovered", arguments: device)
                    case .failure(let error):
                        result(FlutterError(code: "UNAVAILABLE", message: "Failed to fetch peripherals: \(error.localizedDescription)", details: nil))
                    }
                }
            case "getPower":
                self.getPower() { res in
                    switch  res {
                    case .success(let power):
                        result(power)
                    case .failure(let error):
                        result(FlutterError(code: "UNAVAILABLE", message: "Failed to Get the Power: \(error.localizedDescription)", details: nil))
                    }
                }
            case "setPower":
                if let args = call.arguments as? [String: Int], let power = args["powerLevel"] {
                    self.setPower(power: power ) { res in
                        switch  res {
                        case .success(let isPowerSet):
                            result(isPowerSet)
                        case .failure(let error):
                            result(FlutterError(code: "UNAVAILABLE", message: "Failed to Set the Power: \(error.localizedDescription)", details: nil))
                        }
                    }
                }
                
            case "connect":
                    if let args = call.arguments as? [String: String?] {
                        self.connect(deviceData: args) { res in
                            switch  res {
                            case .success(let isConnected):
                                result(isConnected)
                            case .failure(let error):
                                result(FlutterError(code: "UNAVAILABLE", message: "Failed to Connect device: \(error.localizedDescription)", details: nil))
                            }
                        }
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for connectToDevice", details: nil))
                    }
            case "disConnect":
                self.disConnect() { res in
                    switch  res {
                    case .success(let isConnected):
                        result(isConnected)
                    case .failure(let error):
                        result(FlutterError(code: "UNAVAILABLE", message: "Failed to Connect device: \(error.localizedDescription)", details: nil))
                    }
                }
            case "getBatteryLevel":
                self.getBatteryLevel() { res in
                    switch  res {
                    case .success(let battery):
                        result(battery)
                    case .failure(let error):
                        result(FlutterError(code: "UNAVAILABLE", message: "Failed to get baater level: \(error.localizedDescription)", details: nil))
                    }
                }
            case "startScanning":
                self.startScanning() { res in
                    if let eventSink = self.streamHandler.eventSink {
                        switch res {
                        case .success(let tagData):
                            eventSink(tagData)
                        case .failure(let error):
                            eventSink(FlutterError(code: "SCAN_FAILED", message: error.localizedDescription, details: nil))
                        }
                    }
                }
            case "stopScanning":
                self.stopScanning() { res in
                    switch res {
                    case .success(let tagData):
                       result(tagData)
                    case .failure(let error):
                        result(FlutterError(code: "SCAN_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            case "clearAllTags":
                self.clearAllTags() { res in
                    switch res {
                    case .success(let tagData):
                        result(tagData)
                    case .failure(let error):
                        result(FlutterError(code: "SCAN_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            case "clearSingleTag":
                    if  let args = call.arguments as? String {
                        self.clearSingleTag(epc: args) { res in
                            switch res {
                                case .success(let tagData):
                                    result(tagData)
                                case .failure(let error):
                                    result(FlutterError(code: "SCAN_FAILED", message: error.localizedDescription, details: nil))
                            }
                        }}
            case "checkReaderConnectivity":
                self.checkReaderConnectivity() { res in
                    switch res {
                    case .success(let isConnected):
                        result(isConnected)
                    case .failure(let error):
                        result(FlutterError(code: "SCAN_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            case "stopCheckingReaderConnectivity":
                self.stopCheckingReaderConnectivity()
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func enableBluetooth(result: @escaping FlutterResult) {
        switch centralManager.state {
        case .poweredOn:
            result(true)
        case .poweredOff:
            result(false)
            showBluetoothAlert()
        default:
            result(false)
            showBluetoothAlert()
        }
    }
    
    private func showBluetoothAlert() {
        let alertController = UIAlertController(title: "Bluetooth is Off",
                                                message: "Please enable Bluetooth in Settings",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func getAvailableDevices(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // First, set up the completion handler
        intractor.getDiscoveredPeripherals { result in
            switch result {
            case .success(let peripheralData):
                // Directly pass the peripheral data to the completion handler
                completion(.success(peripheralData))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        // Then, start the BLE scan
        intractor.startBLEScan()
    }
    
    private func startBluetoothDiscovery(result: @escaping FlutterResult) {
        discoveredDevices.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        result(nil)
    }
    
    private func makeDeviceDiscoverable(result: @escaping FlutterResult) {
        // iOS devices are always discoverable when the app is in the foreground
        result(nil)
    }
    
    private func connect(deviceData: [String:String?], completion: @escaping (Result<Bool, Error>) ->Void) {
        let result =  intractor.connectToDevice(deviceData: deviceData) { res in
            switch res {
            case .success(let connected):
                completion(.success(connected))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to connect To device"])
                completion(.failure(error))
            }
        }
    }
    
    private func disConnect(completion: @escaping (Result<Bool, Error>) ->Void) {
        intractor.disconnect { res in
            switch res {
            case .success(let disConnected):
                completion(.success(disConnected))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to connect To device"])
                completion(.failure(error))
            }
        }
    }
    
    private func getBatteryLevel(completion: @escaping (Result<Int, Error>) ->Void) {
        intractor.getBatteryLevel { res in
            switch res {
            case .success(let battery):
                completion(.success(battery))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to fetch battery percentage."])
                completion(.failure(error))
            }
        }
    }
    
    
    
    //this method is use to get power
    private func getPower(completion: @escaping (Result<Int, Error>) -> Void) {
        intractor.getPowerLevel { res in
            switch res {
            case .success(let power):
                completion(.success(power))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to get Power"])
                completion(.failure(error))
            }
        }
    }
    
    // this method is setting the power of 1 or 30
    private func setPower(power:Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        intractor.setPowerLevel(powerLevel: power) { res in
            switch res {
            case .success(let isSet):
                completion(.success(isSet))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to set Power"])
                completion(.failure(error))
            }
        }
    }
    
    // this method is setting for Start tag scan
    private func startScanning(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        intractor.startScan() { res in
            switch res {
            case .success(let data):
                completion(.success(data))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to set Power"])
                completion(.failure(error))
            }
        }
    }
    
    // this method is setting for Stop tag scan
    private func stopScanning(completion: @escaping (Result<Bool, Error>) -> Void) {
        intractor.stopScan() { res in
            switch res {
            case .success(let data):
                completion(.success(data))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to set Power"])
                completion(.failure(error))
            }
        }
    }
    
    // this method is setting for Start tag scan
    private func clearAllTags(completion: @escaping (Result<Bool, Error>) -> Void) {
        intractor.cleanAllTags() { res in
            switch res {
            case .success(let data):
                completion(.success(data))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to set Power"])
                completion(.failure(error))
            }
        }
    }
    
    // this method is setting for Start tag scan
    private func clearSingleTag(epc: String,completion: @escaping (Result<Bool, Error>) -> Void) {
        intractor.cleanTag(epc){ res in
            switch res {
            case .success(let data):
                completion(.success(data))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to set Power"])
                completion(.failure(error))
            }
        }
    }
    
    private func checkReaderConnectivity(completion: @escaping (Result<Bool, Error>) -> Void) {
        intractor.checkReaderConnectivity() { res in
            switch res {
            case .success(let data):
                completion(.success(data))
            case.failure:
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not able to set Power"])
                completion(.failure(error))
            }
        }
    }
    
    private func stopCheckingReaderConnectivity() {
        intractor.stopCheckingReaderConnectivity()
    }
    
}

extension AppDelegate: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is available.")
        case .poweredOff, .unauthorized, .unknown, .resetting, .unsupported:
            print("Bluetooth is not available.")
        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(peripheral) {
            discoveredDevices.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        flutterResult?(true)
        flutterResult = nil
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown Device")")
        flutterResult?(FlutterError(code: "CONNECTION_FAILED", message: "Failed to connect to device", details: error?.localizedDescription))
        flutterResult = nil
    }
       
}

class MyStreamHandler: NSObject, FlutterStreamHandler {

    var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
