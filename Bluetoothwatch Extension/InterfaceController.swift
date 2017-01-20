//
//  InterfaceController.swift
//  Bluetoothwatch Extension
//
//  Created by yesway on 2017/1/19.
//  Copyright © 2017年 joker. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import UserNotifications

class InterfaceController: WKInterfaceController {

    private var session: WCSession?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    private var center = UNUserNotificationCenter.current() {
        didSet {
            center.requestAuthorization(options: [.sound,.alert]) { (granted, error) in
                
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        session = WCSession.default()
        session?.delegate = self
        session?.activate()
        
        notifition()
    }
    
    func notifition() {
        let generalCategory = UNNotificationCategory(identifier: "GENERAL",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)
        
        // Create the custom actions for the TIMER_EXPIRED category.
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION",
                                                title: "Snooze",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let stopAction = UNNotificationAction(identifier: "STOP_ACTION",
                                              title: "Stop",
                                              options: .foreground)
        
        let expiredCategory = UNNotificationCategory(identifier: "TIMER_EXPIRED",
                                                     actions: [snoozeAction, stopAction],
                                                     intentIdentifiers: [],
                                                     options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the notification categories.
        center.setNotificationCategories([generalCategory, expiredCategory])

    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
}
