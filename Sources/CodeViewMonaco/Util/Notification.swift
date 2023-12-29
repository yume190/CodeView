//
//  Notification.swift
//  CodeView
//
//  Created by Yume on 2023/3/6.
//

import Foundation

public extension NSNotification.Name {
    static let save = Notification.Name(rawValue: "com.codeview.save")
    static let loadCode = Notification.Name(rawValue: "com.codeview.loadCode")
}
