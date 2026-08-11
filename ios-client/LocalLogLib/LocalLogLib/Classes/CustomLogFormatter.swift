//
//  CustomLogFormatter.swift
//  LocalLogLib
//
//  Created by phl on 2025/9/22.
//

import UIKit
import CocoaLumberjack

class CustomLogFormatter: NSObject, DDLogFormatter {

    let dateFormatter: DateFormatter
    
    override init() {
        dateFormatter = DateFormatter()
        super.init()
        
        // 设置时间格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        // 设置为东八区（DDLog默认0区，需要定义成东八区）
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8")
    }
    
    func format(message logMessage: DDLogMessage) -> String? {
        let timestamp = dateFormatter.string(from: logMessage.timestamp)
        return "\(timestamp) \(logMessage.message)"
    }
}
