//
//  Created by yesway on 2016/11/7.
//  Copyright © 2016年 joker. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = "通知"//notification.request.content.body
        let userInfo = notification.request.content.userInfo
        guard let content = userInfo["content"] as? String,
            let url = userInfo["imageURL"] as? String else {
            return
        }
        textView.text = content
        image.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
    }

}
