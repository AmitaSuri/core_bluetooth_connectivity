import CoreBluetooth
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate{
    var intractor:BluetoothInteractor = BluetoothInteractor()
    private var centralManager: CBCentralManager!
    private var discoveredDevices: [CBPeripheral] = []
    private var flutterResult: FlutterResult?
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller = window?.rootViewController as! FlutterViewController
        let bluetoothChannel = FlutterMethodChannel(name: "samples.flutter.dev/bluetooth",
                                                    binaryMessenger: controller.binaryMessenger)
        bluetoothChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            switch call.method {
            case "enableBluetooth":
                self.enableBluetooth(result: result)
            case "getAvailableDevices":
                self.getAvailableDevices { res in
                    switch res {
                    case .success(let model):
                        result(model)
                    case .failure(let error):
                        result(FlutterError(code: "UNAVAILABLE", message: "Failed to fetch peripherals: \(error.localizedDescription)", details: nil))
                    }
                }
            case "getPower":
                self.getPower(completion: result)
            case "setPower":
                if let args = call.arguments as? [String: Int], let power = args["powerLevel"] {
                    self.setPower(power: power, completion: result)
                }
                
            case "connect":
                if let args = call.arguments as? [String: Any]{
                    self.connect(deviceData: args, completion: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for connectToDevice", details: nil))
                }
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
    
    //    private func getAvailableDevices(completion: @escaping (Result<[String: Any], Error>) -> Void) {
    //        intractor.startBLEScan()
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){ [weak self] in
    //            self?.intractor.getDiscoveredPeripherals { result in
    //                switch result {
    //                case .success(let models):
    //                    if let firstModel = models.first,
    //                       let name = firstModel["name"] as? String,
    //                       let address = firstModel["address"] as? String{
    //                        let resultDict: [String?: String?] = [
    //                            "name": name,
    //                            "address": address
    //                        ]
    //                        completion(.success(resultDict))
    //                    } else {
    //                        completion(.failure(NSError(domain: "com.example.Bluetooth", code: 404, userInfo: [NSLocalizedDescriptionKey: "No peripherals found"])))
    //                    }
    //
    //                case .failure(let error):
    //                    completion(.failure(error))
    //                }
    //            }
    //        }
    //    }
    
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
    
    private func connect(deviceData: [String:Any], completion: @escaping (Result<Bool, Error>) ->Void) {
        //        let deviceData: [String,String] = ["address":deviceName];
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
