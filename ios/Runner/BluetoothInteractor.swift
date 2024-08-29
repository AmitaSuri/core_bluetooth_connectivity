//
//  BluetoothManager.swift
//  RFIDReaderDemo
//
//  Created by Ayush Jain on 28/08/24.
//

import UIKit
import CoreBluetooth

class BluetoothInteractor: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, FatScaleBluetoothManager {
    
    private var discoveredPeripherals: [BLEModel] = []
    private var selectedPeripheral: CBPeripheral?
    private var connectedPeripherals: [CBPeripheral] = []
    private var macAddress = ""
    private var uuidDataList = [String]()
    private var myCharacteristic: CBCharacteristic?
    private var uhfData = NSMutableData()
    private var isConnect: Bool = false
    
    private var currentPowerLevel: Int?
    private var setPowerLevelSuccess: Bool?
    private var batteryLevel: String?
    weak var managerDelegate: FatScaleBluetoothManager?
    private var peripheralCompletion: ((Result<[String: Any], Error>) -> Void)?
    private var setPowerLevelCompletion: ((Result<Bool, Error>) -> Void)?
    private var getPowerLevelCompletion: ((Result<Int, Error>) -> Void)?
    private var deviceConnectionCompletion: ((Result<Bool, Error>) -> Void)?
    
    override init() {
        super.init()
        RFIDBlutoothManager.share().setFatScaleBluetoothDelegate(self)
    }
    
    func connectToDevice(deviceData: [String: String?], completion: @escaping (Result<Bool, Error>) -> Void) {
            guard let address = deviceData["address"] as? String else {
                print("Invalid address")
                completion(.failure(NSError(domain: "InvalidAddress", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid address"])))
                return
            }

            // Store the completion handler
            deviceConnectionCompletion = completion

            // Find the BLEModel that matches the provided address
        if let model = discoveredPeripherals.first(where: { $0.peripheral.identifier.uuidString == address }) {
                RFIDBlutoothManager.share().connect(model.peripheral, macAddress: model.addressStr)
            } else {
                print("Peripheral with address \(address) not found")
                completion(.failure(NSError(domain: "PeripheralNotFound", code: -1, userInfo: [NSLocalizedDescriptionKey: "Peripheral with address \(address) not found"])))
            }
        }

    func startBLEScan() {
        // Start scanning for BLE peripherals
        RFIDBlutoothManager.share().bleDoScan()
    }
    
    func getDiscoveredPeripherals(completion: @escaping (Result<[String: Any], Error>) -> Void) {
            // Store the completion handler to call back as peripherals are discovered
            peripheralCompletion = completion
        }
    
    
    // For getting the power level
        func getPowerLevel(completion: @escaping (Result<Int, Error>) -> Void) {
            // Store the completion handler to be called when the power level is received
            getPowerLevelCompletion = completion
            
            // Request the power level
            RFIDBlutoothManager.share().getLaunchPower()
            print("Power level request initiated")
        }
    
    // For setting the power level
    func setPowerLevel(powerLevel: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        // Store the completion handler to be called when the power level is set
        setPowerLevelCompletion = completion
        
        // Validate the power level input
        guard (powerLevel == 1 || powerLevel == 30) else {
            let error = NSError(domain: "INVALID_ARGUMENT", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid power level: \(powerLevel). Only 1 or 30 are allowed."])
            print("Invalid power level: \(powerLevel). Only 1 or 30 are allowed.")
            completion(.failure(error))
            return
        }
        
        // Request to set the power level
        RFIDBlutoothManager.share().setLaunchPowerWithstatus("1", antenna: "1", readStr: "\(powerLevel)", writeStr: "\(powerLevel)")
        print("Set power level request initiated")
    }
    
    func getBatteryLevel(completion: @escaping (Result<String, Error>) -> Void) {
        do {
            // Request the battery level
            RFIDBlutoothManager.share().getBatteryLevel()
            
            // Wait for the response from the delegate method
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let batteryLevel = self.batteryLevel {
                    print("Got battery level: \(batteryLevel)")
                    completion(.success(batteryLevel))
                } else {
                    print("Battery level not available")
                    completion(.failure(NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Battery level not available"])))
                }
            }
        }
    }
    
    // MARK: - FatScaleBluetoothManager Methods
    func rfidConfig(_ data: String, function: Int) {
        switch function {
        case 0x01:
            let hardwareVersion = "Hardware Versions: \(data)"
            print(hardwareVersion)
            
        case 0x03:
            let firmwareVersion = "RFID Firmware Versions: \(data)"
            print(firmwareVersion)
            
        case 0xC9:
            let mainboardVersion = "Mainboard Version: \(data)"
            print(mainboardVersion)
            
        case 0x2D:
            let msg = data == "1" ? "success" : "fail"
            print(msg)
            
        case 0x2F:
            print("TO be decided")
            
        case 0x11:
            let success = data == "1"
            setPowerLevelSuccess = success
            print(success ? "Set power level successfully" : "Failed to set power level")
            
            // Call the stored completion handler with the success status
            setPowerLevelCompletion?(.success(success))
            
            // Clear the completion handler after use
            setPowerLevelCompletion = nil
            
        case 0x13:
            if let powerLevel = Int(data) {
                currentPowerLevel = powerLevel
                print("Read power level successfully: \(powerLevel)")
                
                // Call the stored completion handler with the power level
                getPowerLevelCompletion?(.success(powerLevel))
            } else {
                print("Failed to read power level")
                let error = NSError(domain: "UNAVAILABLE", code: -1, userInfo: [NSLocalizedDescriptionKey: "Power level not available."])
               getPowerLevelCompletion?(.failure(error))
            }
            
            // Clear the completion handler after use
           getPowerLevelCompletion = nil
            
        case 0x15:
            let msg = data == "1" ? "success" : "fail"
            print(msg)
            
        case 0x35:
            let msg = data == "-1" ? "fail" : "Temperature: \(data)℃"
            print(msg)
            
        case 0x71:
            let msg = data == "1" ? "success" : "fail"
            print(msg)
            
        case 0x73:
            let components = data.split(separator: " ")
            if components.count >= 3 {
                let type = String(components[0])
                let userPtr = String(components[1])
                let userLen = String(components[2])
                print("Read success: Type: \(type), UserPtr: \(userPtr), UserLen: \(userLen)")
            } else {
                print("fail")
            }
            
        case 0xC1:
            if data != "1" {
                print("Failure to enter update mode!")
                return
            }
            RFIDBlutoothManager.share().startUpgrade()
            
        case 0xC3:
            if data != "1" {
                print("Failure to start upgrade!")
                return
            }
            
        case 0xC5:
            print("TO be Decided")
            
        case 0xC7:
            if data != "1" {
                print("Upgrade failed!")
                return
            }
            print("Upgrade successful")
            
        case 0xE5:
            batteryLevel = data
            let batteryLevelPer = "Battery: \(data)%"
            print(batteryLevelPer)
            
        case 0xE500, 0xE501:
            let msg = data == "1" ? "success" : "fail"
            print(msg)
            
        case 0xE6:
            if let keyCode = Int(data) {
                print("keyCode=\(keyCode)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    //
                }
            }
            
        case 0xE31, 0xE35:
            print(data)
            
        case 0xE32:
            print("Get Key Success")
            
        case 0xE33:
            print("Encryption success")
            
        case 0xE34:
            print("Decryption success")
            
        case 0xE36:
            print("read success")
            
        default:
            break
        }
    }
    
    func rfidSetFilterCallback(_ message: String, isSuccess: Bool) {}
    
    func rfidReadLabelCallback(_ data: String, isSuccess: Bool) {}
    
    func rfidWriteLabelCallback(_ data: String, isSuccess: Bool) {}
    
    func rfidLockLabelCallback(_ data: String, isSuccess: Bool) {}
    
    func rfidKillLabelCallback(_ data: String, isSuccess: Bool) {}
    
    func rfidBarcodeLabelCallBack(_ data: Data) {}
    
    func rfidTagInfoCallback(_ tag: UHFTagInfo) {}
    
    func connectBluetoothFail(withMessage message: String) {
        // blutooth fail
    }
    
    func receiveData(withBLEmodel model: BLEModel?, result: String) {
        if result == "0", let model = model {
            
            // Check if the peripheral has the required prefix and hasn't been added already
            if let name = model.nameStr, name.hasPrefix("UR"),
            !discoveredPeripherals.contains(where: { $0.peripheral.identifier.uuidString == model.peripheral.identifier.uuidString }) {
                discoveredPeripherals.append(model)
                
                // Notify the completion handler for each newly discovered peripheral
                let peripheralData: [String: String] = [
                    "name": model.nameStr,
                    "address": model.peripheral.identifier.uuidString
                ]
                peripheralCompletion?(.success(peripheralData))
            }
        }
    }
    
    func disConnectPeripheral() {}
    
    func connectPeripheralSuccess(_ name: String?) {
            // Device got connected
            deviceConnectionCompletion?(.success(true))
            deviceConnectionCompletion = nil // Reset the completion handler after use
        }
    
    func receiveGetGen2(with data: Data?) {}
    
    func receiveSetGen2(withResult isSuccess: Bool) {}
    
    func receiveSetFilter(withResult isSuccess: Bool) {}
    
    func receiveSetRFLink(withResult isSuccess: Bool) {}
    
    func receiveGetRFLinkWithData(_ data: Int) {}
    
    // MARK: - CBCentralManagerDelegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Handle different states here...
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Handle successful connection...
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // Handle connection failure...
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Handle disconnection...
    }
    
    // Add other necessary delegate methods...
}
