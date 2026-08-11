//
//  CustomLogFileManager.swift
//  LocalLogLib
//
//  Created by phl on 2025/9/22.
//

import UIKit
import CocoaLumberjack

class CustomLogFileManager: DDLogFileManagerDefault {
    // 获取东八区时间
    private var dateFormatter: DateFormatter
    
    override init(logsDirectory: String?) {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        self.dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8") // 设置为东八区
        super.init(logsDirectory: logsDirectory)
        
        // 打印调试信息
        print("CustomLogFileManager 初始化，日志目录: \(logsDirectory ?? "nil")")
    }
    
    // 自定义文件名，使用东八区时间戳
    override func createNewLogFile() throws -> String {
        let timestamp = dateFormatter.string(from: Date())
        let logFileName = "log_\(timestamp).txt"
        let logFilePath = (self.logsDirectory as NSString).appendingPathComponent(logFileName)
        
        // 检查文件夹是否存在，如果不存在就创建
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: self.logsDirectory) {
            try fileManager.createDirectory(atPath: self.logsDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        // 如果文件已经存在，先删除旧的文件
        if fileManager.fileExists(atPath: logFilePath) {
            try fileManager.removeItem(atPath: logFilePath)
        }
        
        // 创建空文件，确保文件存在且可写
        let success = fileManager.createFile(atPath: logFilePath, contents: nil, attributes: nil)
        if !success {
            throw NSError(domain: "CustomLogFileManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建日志文件: \(logFilePath)"])
        }
        
        // 验证文件是否可写
        if !fileManager.isWritableFile(atPath: logFilePath) {
            throw NSError(domain: "CustomLogFileManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "日志文件不可写: \(logFilePath)"])
        }
        
        print("成功创建日志文件: \(logFilePath)")
        return logFilePath
    }
}
