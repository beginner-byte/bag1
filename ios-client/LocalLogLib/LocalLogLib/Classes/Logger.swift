//
//  Logger.swift
//  LocalLogLib
//
//  Created by phl on 2025/9/22.
//

import UIKit
import CocoaLumberjack

@objcMembers
public class Logger: NSObject {
    
    // 静态变量，表示日志开关，默认值为 false（关闭日志）
    public static var isLoggingEnabled: Bool = false
    
    // 设置日志开关
    public static func setLoggingEnabled(_ enabled: Bool) {
        isLoggingEnabled = enabled
    }
    
    /// 初始化配置
    public static func setUp() -> Bool {
        // 配置日志输出目标
        DDLog.add(DDOSLogger.sharedInstance) // 输出到 Xcode 控制台
        
        // 配置文件输出
        guard let cacheDir: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
#if DEBUG
            print("错误: 无法获取缓存目录")
#endif
            return false
        }
        
        let logDir: URL = cacheDir.appendingPathComponent("Logs")
#if DEBUG
        print("日志文件path = \(logDir.path)")
#endif
        
        do {
            // 如果文件夹不存在，创建日志文件夹
            if !FileManager.default.fileExists(atPath: logDir.path) {
                try FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true, attributes: nil)
#if DEBUG
                print("创建日志目录: \(logDir.path)")
#endif
            }
            
            // 验证目录是否可写
            if !FileManager.default.isWritableFile(atPath: logDir.path) {
#if DEBUG
                print("错误: 日志目录不可写: \(logDir.path)")
#endif
                return false
            }
            
            // 配置存储路径
            let customFileManager = CustomLogFileManager(logsDirectory: logDir.path)
            let fileLogger = DDFileLogger(logFileManager: customFileManager)
            
            // 自定义日志格式化
            let customFormatter = CustomLogFormatter()
            fileLogger.logFormatter = customFormatter
            
            // 每个文件最大 5MB
            fileLogger.maximumFileSize = 1024 * 1024 * 5
            // 保留最多 5 个日志文件
            fileLogger.logFileManager.maximumNumberOfLogFiles = 5
            // 设置日志轮转时间（24小时）
            fileLogger.rollingFrequency = 24 * 60 * 60
            
            // 添加文件日志器
            DDLog.add(fileLogger)
#if DEBUG
            print("日志组件初始化成功")
#endif
            return true
        } catch {
#if DEBUG
            print("初始化日志组件失败，error = \(error)")
#endif
            return false
        }
    }
    
    /// 最详细等级日志
    /// - Parameter message: 日志
    public static func verbose(_ message: String) {
        if !isLoggingEnabled {
            return
        }
        DDLogVerbose("\(message)")
    }
    
    /// 调试日志-Release环境禁用
    /// - Parameter message: 日志
    public static func debug(_ message: String) {
        if !isLoggingEnabled {
            return
        }
        DDLogDebug("\(message)")
    }
    
    /// 信息级别日志
    /// - Parameter message: 日志
    public static func info(_ message: String) {
        if !isLoggingEnabled {
            return
        }
        DDLogInfo("\(message)")
    }
    
    /// 警告日志
    /// - Parameter message: 日志
    public static func warn(_ message: String) {
        if !isLoggingEnabled {
            return
        }
        DDLogWarn("\(message)")
    }
    
    /// 异常日志
    /// - Parameter message: 日志
    public static func error(_ message: String) {
        if !isLoggingEnabled {
            return
        }
        DDLogError("\(message)")
    }
    
    /// 设置log日志
    /// - Parameters:
    ///   - level: 等级
    ///   - message: 日志
    public static func log(_ level: DDLogLevel, message: String) {
        if !isLoggingEnabled {
            return
        }
        switch level {
        case .verbose:
            DDLogVerbose("\(message)")
        case .debug:
            DDLogDebug("\(message)")
        case .info:
            DDLogInfo("\(message)")
        case .warning:
            DDLogWarn("\(message)")
        case .error:
            DDLogError("\(message)")
        default:
            break
        }
    }
}
