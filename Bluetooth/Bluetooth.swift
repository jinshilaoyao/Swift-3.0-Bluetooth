//
//  Bluetooth.swift
//  Bluetooth
//
//  Created by yesway on 16/9/29.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BluetoothDelegate: NSObjectProtocol {
    func blueToothDidDiscoverPeripheral()
    func blueToothClear()
}

class Bluetooth: NSObject {
    
    static let shareBlueTooth = Bluetooth()
    
    fileprivate var centralManager: CBCentralManager?
    
    var peripheralArray = [CBPeripheral]()
    
    var delegate: BluetoothDelegate?
    
    func start() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connectPeripheral(peripheral: CBPeripheral) {
        centralManager?.connect(peripheral, options: nil)
    }
    
    func discoverService(peripheral: CBPeripheral) {
//        let uuidService = CBUUID(string: "312700E2-E798-4D5C-8DCF-49908332DF9F")
        
//        peripheral.discoverServices([uuidService])
        peripheral.discoverServices(nil)
    }
    
    func sendAPPSetlight(peripheral: CBPeripheral) {
        
        let data = Data(base64Encoded: "joker")
        
    }
    func getAllCharacteristic(cbCharArray: [CBCharacteristic], forService service: CBService) {
        
    }
    
}

extension Bluetooth: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print(error)
        } else {
            for service in peripheral.services! {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            
        } else {
            print("OK")
            getAllCharacteristic(cbCharArray: service.characteristics!, forService: service)
            
        }
        
    }
    
}

extension Bluetooth: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("CBCentralManagerStateUnknown")
            break
        case .resetting:
            print("CBCentralManagerStateResetting")
            break
        case .unsupported:
            print("CBCentralManagerStateUnSupported")
            break
        case .unauthorized:
            print("CBCentralManagerStateUnAuthorized")
            break
        case .poweredOff:
            print("CBCentralManagerStatePowerOff")
            break
        case .poweredOn:
            print("CBCentralManagerStateProwerOn")
            peripheralArray.removeAll()
            delegate?.blueToothClear()
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheralArray.contains(peripheral) {
            
        } else {
            peripheralArray.append(peripheral)
            delegate?.blueToothDidDiscoverPeripheral()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        centralManager?.stopScan()
        peripheral.delegate = self
        discoverService(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("\(peripheral.name) --- \(error)")
    }
    
    
}
