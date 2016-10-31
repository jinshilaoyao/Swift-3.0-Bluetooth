//
//  Bluetooth.swift
//  Bluetooth
//
//  Created by yesway on 16/9/29.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications


protocol BluetoothDelegate: NSObjectProtocol {
    func blueToothDidDiscoverPeripheral()
    func blueToothClear()
}

class Bluetooth: NSObject {
    
    static let shareBlueTooth = Bluetooth()
    
    fileprivate var centralManager: CBCentralManager?
    
    fileprivate var currentPeripheral: CBPeripheral?
    
    var peripheralArray = [CBPeripheral]()
    
    var delegate: BluetoothDelegate?
    
    var timer: Timer?
    
    var completionCallBack: (() -> Void)?
    
    var failToConnectCallBack: (() -> Void)?
    
    var getdistance: ((_ distance: Double) -> Void)?
    
    func start() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connectPeripheral(peripheral: CBPeripheral, completion: @escaping (() ->())) {
        centralManager?.connect(peripheral, options: nil)
        completionCallBack = completion
    }
    
    func discoverService(peripheral: CBPeripheral) {

        peripheral.discoverServices(nil)
    }
    
    func sendAPPSetlight(peripheral: CBPeripheral) {
        
        
    }
    func getAllCharacteristic(cbCharArray: [CBCharacteristic], forService service: CBService) {
        
    }
    
    fileprivate func startGetDistanceBetweenEquipments() {
        timer = Timer(timeInterval: 1.5, target: self, selector: #selector(readRSSI), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    fileprivate func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func readRSSI() {
        currentPeripheral?.readRSSI()
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
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
        if error != nil {
            print(error)
        } else {
            let rssi = abs(RSSI.int32Value)
            let power = Double((rssi - 59))/2.0
            let temp = pow(10.0, power)
            if temp >= 100 {
                createReminderNotification(for: "设备正在远离！！")
            }
            getdistance?(Double(rssi))
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
        
        guard let name = peripheral.name else {
            return
        }
        
        if peripheralArray.contains(peripheral) {
            
        } else {
            if name.characters.count > 0 {
                peripheralArray.append(peripheral)
                delegate?.blueToothDidDiscoverPeripheral()
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        centralManager?.stopScan()
        
        peripheral.delegate = self
        currentPeripheral = peripheral
        
        startGetDistanceBetweenEquipments()
        
        if completionCallBack != nil {
            completionCallBack?()
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("\(peripheral.name) --- \(error)")
        let text = "\(peripheral.name) - 断开链接"
        createReminderNotification(for: text)
        stop()
        if (failToConnectCallBack != nil) {
            failToConnectCallBack?()
        }
    }
    
    
    
    
    /// Creates a notification for the given task, repeated every minute.
    func createReminderNotification(for task: String) {
        // Configure our notification's content
        let content = UNMutableNotificationContent()
        content.title = "BlueTooch"
        content.body = "\(task)!!" // Important to include this, otherwise notification won't display
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = Identifiers.reminderCategory
        
        // We want the notification to nag us every 60 seconds (the minimum time-interval Apple allows us to repeat at)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        
        // Simply use the task name as our identifier. This means we have a single notification per task... any other notifications created with same identifier will overwrite the existing notification.
        let identifier = "\(task)"
        
        // Construct the request with the above components
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) {
            error in
            if let error = error {
                print("Problem adding notification: \(error.localizedDescription)")
            }
            else {
                // Set icon
                DispatchQueue.main.async {
                    
                }
            }
        }
    }
}
