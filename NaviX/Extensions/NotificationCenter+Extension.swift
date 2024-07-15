//
//  NotificationCenter+Extension.swift
//  NaviX
//
//  Created by Helloyunho on 7/14/24.
//

import Foundation

extension NotificationCenter {
    func postMain(
        name: Notification.Name, object: sending Any?=nil, userInfo: sending [AnyHashable: Any]?=nil
    ) {
        DispatchQueue.main.async {
            self.post(name: name, object: object, userInfo: userInfo)
        }
    }
}
