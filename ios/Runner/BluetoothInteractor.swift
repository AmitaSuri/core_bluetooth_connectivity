//
//  BluetoothManager.swift
//  RFIDReaderDemo
//
//  Created by Ayush Jain on 28/08/24.
//

import UIKit
import CoreBluetooth

class BluetoothInteractor: NSObject, CBPeripheralDelegate, FatScaleBluetoothManager {
    
    private var discoveredPeripherals: [BLEModel] = []
    private var macAddress = ""
    private var myCharacteristic: CBCharacteristic?
    private var uhfData = NSMutableData()
    var sentTags: Set<String> = []
    private var currentPowerLevel: Int?
    private var setPowerLevelSuccess: Bool?
    private var batteryLevel: Int?
    weak var managerDelegate: FatScaleBluetoothManager?
    private var tagInfo = [UHFTagInfo]()
    private var isRunning = false
    private var timer: Timer?
    var onTagDiscovered: ((Result<[String: Any], Error>) -> Void)?
    private var peripheralCompletion: ((Result<[String: Any], Error>) -> Void)?
    private var setPowerLevelCompletion: ((Result<Bool, Error>) -> Void)?
    private var getPowerLevelCompletion: ((Result<Int, Error>) -> Void)?
    private var deviceConnectionCompletion: ((Result<Bool, Error>) -> Void)?
    private var disconnectCompletion: ((Result<Bool, Error>) -> Void)?
    private var batteryLevelCompletion: ((Result<Int, Error>) -> Void)?
    
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
    
    func disconnect(completion: @escaping (Result<Bool, Error>) -> Void) {
        // Store the completion handler to be called when disconnection is confirmed
        disconnectCompletion = completion
        discoveredPeripherals.removeAll()
        RFIDBlutoothManager.share().softwareReset()
        // Initiate disconnection
        RFIDBlutoothManager.share().closeBleAndDisconnect()
        print("Disconnection initiated")
    }
    
    func startBLEScan() {
        // Start scanning for BLE peripherals
        RFIDBlutoothManager.share().bleDoScan()
    }
    
    func getDiscoveredPeripherals(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        discoveredPeripherals.removeAll()
        // Store the completion handler to call back as peripherals are discovered
        peripheralCompletion = completion
    }
    
    func stopScanningBleDevices(completion: @escaping (Result<Bool, Error>) -> Void) {
        RFIDBlutoothManager.share().stopBluetoothScan()
        completion(.success(true))
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
    
    func getBatteryLevel(completion: @escaping (Result<Int, Error>) -> Void) {
        // Store the completion handler to be called when the battery level is received
        batteryLevelCompletion = completion
        
        // Request the battery level
        RFIDBlutoothManager.share().getBatteryLevel()
        print("Battery level request initiated")
    }
    
    func startScan(onTagDiscovered: @escaping (Result<[String: Any], Error>) -> Void) {
        self.onTagDiscovered = onTagDiscovered
        RFIDBlutoothManager.share().startInventory()
    }
    
    func stopScan(completion: @escaping (Result<Bool, Error>) -> Void) {
        RFIDBlutoothManager.share().stopInventory()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(!RFIDBlutoothManager.share().isgetLab))
        }
    }
    
    func cleanAllTags(completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            tagInfo.removeAll()  // Clear all tags
            sentTags.removeAll()
            print("All tags have been cleaned.")
            completion(.success(true))
        }
    }
    
    func cleanTag(_ tag: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        if let index = tagInfo.firstIndex(where: { $0.epc == tag }), let sentIndex = sentTags.firstIndex(of: tag) {
            sentTags.remove(at: sentIndex)
            tagInfo.remove(at: index)  // Remove the specific tag
            print("Tag with EPC: \(tag)")
            completion(.success(true))
        } else {
            let error = NSError(domain: "TAG_NOT_FOUND", code: -1, userInfo: [NSLocalizedDescriptionKey: "Tag not found in the list."])
            print("Failed to clean tag: Tag not found.")
            completion(.failure(error))
        }
    }
    
    func checkReaderConnectivity(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard RFIDBlutoothManager.share().connectDevice == true else {
            print("Device is not connected")
            completion(.success(false))
            return
        }
        
        if isRunning { return }
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let isConnected = RFIDBlutoothManager.share().connectDevice
            if !isConnected {
                print("Disconnected from device")
                completion(.success(false))
            } else {
                print("Still connected to device")
                completion(.success(true))
            }
        }
    }
    
    //........to be tested.........
    func stopCheckingReaderConnectivity() {
        isRunning = false
        timer?.invalidate() // Cancel the timer
        timer = nil // Clear the timer instance
    }
    
    // MARK: - FatScaleBluetoothManager Methods
    @objc func rfidConfigCallback(_ data: String, function: Int) {
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
            if let batteryLevel = Int(data){
                print(batteryLevel)
                
                // Call the stored completion handler with the battery level
                batteryLevelCompletion?(.success(batteryLevel))
            }
            
            // Clear the completion handler after use
            batteryLevelCompletion = nil
            
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
    
    func rfidTagInfoCallback(_ tag: UHFTagInfo) {
        var isHave = false
        
        // Check if the tag already exists in the localDataSource array
        for i in 0..<tagInfo.count {
            let oldEPC = tagInfo[i]
            if (oldEPC.epc + oldEPC.tid) == (tag.epc + tag.tid) {
                isHave = true
                oldEPC.count += 1
                oldEPC.rssi = tag.rssi
                oldEPC.tid = tag.tid
                oldEPC.user = tag.user
                break
            }
        }
        
        // If the tag is not already in the array, add it
        if !isHave {
            tagInfo.append(tag)
        }
        
        // Prepare the tag data dictionary
        let tagData: [String: Any] = [
            "epc": tag.epc,
            "tid": tag.tid,
            "rssi": tag.rssi,
            "count": tag.count,
            "user": tag.user
        ]
        
        // Create a unique identifier for the tag
        let tagIdentifier = "\(tag.epc)"
        
        // Send the tag data one by one if it has not been sent before
        if !sentTags.contains(tagIdentifier) {
            sentTags.insert(tagIdentifier)
            onTagDiscovered?(.success(tagData))
        }
    }
    
    func connectBluetoothFail(withMessage message: String) {
        // blutooth fail
    }
    
    func receiveData(withBLEmodel model: BLEModel?, result: String) {
        if result == "0", let model = model {
            
            // Check if the peripheral has the required prefix and hasn't been added already
//            if let name = model.nameStr, name.hasPrefix("UR"),
             if !discoveredPeripherals.contains(where: { $0.peripheral.identifier.uuidString == model.peripheral.identifier.uuidString }) {
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
    
    func connectPeripheralSuccess(_ name: String?) {
        // Device got connected
        deviceConnectionCompletion?(.success(true))
        deviceConnectionCompletion = nil // Reset the completion handler after use
    }
    
    func disConnectPeripheral() {
        // Assuming connectDevice is a boolean indicating connection status
        let isDisconnected = RFIDBlutoothManager.share().connectDevice == false
        stopCheckingReaderConnectivity()
        
        // Call the completion handler with the result of disconnection
        if let completion = disconnectCompletion {
            completion(.success(isDisconnected))
            // Clear the completion handler after use
            disconnectCompletion = nil
        }
    }
    
    func getConnectedPeripherals(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
            // Call the Objective-C method to get the list of peripherals
        let connectedPeripherals = RFIDBlutoothManager.share().getBluetoothList()
        
            // Check if connectedPeripherals is not nil and is of the expected type
        guard let peripherals = connectedPeripherals as? [CBPeripheral] else {
            completion(.failure(NSError(domain: "InvalidDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve peripherals"])))
            return
        }
        
            // Convert each peripheral into a BLEModel and add it to the discoveredPeripherals array
        var peripheralDataArray: [[String: Any]] = []
        
        for peripheral in peripherals {
            let bleModel = BLEModel()
            bleModel.nameStr = peripheral.name ?? "Unknown"
            bleModel.addressStr = peripheral.identifier.uuidString
            bleModel.peripheral = peripheral
            
            discoveredPeripherals.append(bleModel)
            
            let peripheralData: [String: Any] = [
                "name": bleModel.nameStr,
                "address": bleModel.addressStr
            ]
            peripheralDataArray.append(peripheralData)
        }
        
            // Return the array of dictionaries through the completion handler
        completion(.success(peripheralDataArray))
    }
    
    func receiveGetGen2(with data: Data?) {}
    
    func receiveSetGen2(withResult isSuccess: Bool) {}
    
    func receiveSetFilter(withResult isSuccess: Bool) {}
    
    func receiveSetRFLink(withResult isSuccess: Bool) {}
    
    func receiveGetRFLinkWithData(_ data: Int) {}
    
}
