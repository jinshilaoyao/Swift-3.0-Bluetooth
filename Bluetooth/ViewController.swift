//
//  ViewController.swift
//  Bluetooth
//
//  Created by yesway on 16/9/29.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit
import UserNotifications
import WatchConnectivity

struct Identifiers {
    static let reminderCategory = "reminder"
    static let cancelAction = "cancel"
}

class ViewController: UIViewController {

    fileprivate var bluetooth = Bluetooth.shareBlueTooth
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tableview: UITableView!
    
    
    fileprivate var session: WCSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableview.delegate = self
        tableview.dataSource = self
        bluetooth.delegate = self
        label.isHidden = true
        bluetooth.failToConnectCallBack = { [unowned self] in
            self.label.isHidden = false
            self.tableview.reloadData()
        }
        
        bluetooth.getdistance = { [unowned self] distance in
            self.updateDistanceLabel(distance: distance)
        }
        
        
        
        //watch与手机通信
        session = WCSession.default()
        session?.delegate = self
        session?.activate()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        createReminderNotification(for: "本地测试")
    }

    private func updateDistanceLabel(distance: Double) {
        distanceLabel.text = String(format: "%.2f", distance)
    }
    
    @IBAction func startRequestDeive(_ sender: AnyObject) {
        label.isHidden = true
        bluetooth.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /// Creates a notification for the given task, repeated every minute.
    func createReminderNotification(for task: String) {
        // Configure our notification's content
        let content = UNMutableNotificationContent()
        content.title = "通知样式扩展演示"
        content.body = "\(task)!!" // Important to include this, otherwise notification won't display
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = Identifiers.reminderCategory
        content.userInfo = ["imageURL":"http://www.baidu.com","content":"回家吃饭"]
        
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
extension ViewController: BluetoothDelegate {
    func blueToothDidDiscoverPeripheral() {
        tableview.reloadData()
    }
    
    func blueToothClear() {
        tableview.reloadData()
    }
    
    func blueToothDevicIsLeave() {
        session?.sendMessage(["text": "Leaving.."], replyHandler: nil, errorHandler: nil)
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetooth.peripheralArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let peripheral = bluetooth.peripheralArray[indexPath.row]
        cell.textLabel?.text = peripheral.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = bluetooth.peripheralArray[indexPath.row]
        bluetooth.connectPeripheral(peripheral: peripheral) {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .detailButton
        }
    }
}
extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    

    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    

    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}


