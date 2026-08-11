//
//  ViewController.swift
//  GaOnchainLib
//
//  Created by panghailiang on 12/10/2025.
//  Copyright (c) 2025 panghailiang. All rights reserved.
//

import UIKit
import GaOnchainLib

class ViewController: UIViewController {
    
    // 将 manager 保存为属性，避免被提前释放
    private var manager: NoaGaOnchainManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            manager = NoaGaOnchainManager()
            guard let manager = manager else { return }
            
            let ocConfig:OCConfig = try manager.loadConfig()
            print("ocConfig = \(ocConfig)")
            
            // 保存所有请求任务的数组
            var tasks: [URLSessionDataTask] = []
            // 用于标记是否已经有成功的请求
            var hasSuccess = false
            // 用于跟踪失败的请求数量
            var failureCount = 0
            // 使用锁来保证线程安全
            let lock = NSLock()
            // 总请求数
            let totalCount = ocConfig.rpcNodes.count
            
            // 并发请求所有 RPC 节点
            ocConfig.rpcNodes.forEach { rpcUrl in
                print("发起请求到: \(rpcUrl)")
                
                // 先声明 task 变量，以便在闭包中捕获
                var currentTask: URLSessionDataTask?
                
                currentTask = manager.getValueWithTask(rpcUrl: rpcUrl, completion: { responseStr, error in
                    // 检查是否已经有成功的请求
                    lock.lock()
                    let shouldProcess = !hasSuccess
                    let currentFailureCount = failureCount
                    let allTasks = tasks  // 保存当前所有任务的副本
                    let taskId = currentTask?.taskIdentifier ?? -1  // 获取当前任务的 ID
                    lock.unlock()
                    
                    // 如果已经有成功的请求，不再处理这个回调
                    if !shouldProcess {
                        return
                    }
                    
                    if let error = error {
                        // 请求失败
                        lock.lock()
                        failureCount += 1
                        let newFailureCount = failureCount
                        let stillNoSuccess = !hasSuccess
                        lock.unlock()
                        
                        print("请求\(rpcUrl)失败，error = \(error)")
                        
                        // 如果全部请求都失败了，调用失败接口
                        if stillNoSuccess && newFailureCount >= totalCount {
                            print("所有请求都失败了，共 \(newFailureCount) 个请求")
                            // 这里可以调用失败回调
                            // onAllRequestsFailed?()
                        }
                        return
                    }
                    
                    // 第一个成功的请求
                    lock.lock()
                    if !hasSuccess {
                        hasSuccess = true
                    }
                    lock.unlock()
                    
                    print("请求\(rpcUrl)成功，responseStr = \(responseStr ?? "")")
                    
                    // 取消所有其他任务
                    for otherTask in allTasks {
                        // 通过比较 taskIdentifier 来区分不同的任务
                        if otherTask.taskIdentifier != taskId 
                            && otherTask.state != .canceling 
                            && otherTask.state != .completed {
                            otherTask.cancel()
                            print("已取消任务: \(otherTask.taskIdentifier)")
                        }
                    }
                })
                
                guard let task = currentTask else {
                    print("创建请求任务失败: \(rpcUrl)")
                    // 如果创建任务失败，也算作失败
                    lock.lock()
                    failureCount += 1
                    let newFailureCount = failureCount
                    let stillNoSuccess = !hasSuccess
                    lock.unlock()
                    
                    if stillNoSuccess && newFailureCount >= totalCount {
                        print("所有请求都失败了（包括创建失败），共 \(newFailureCount) 个请求")
                        // 这里可以调用失败回调
                        // onAllRequestsFailed?()
                    }
                    return
                }
                
                // 将 task 添加到数组
                lock.lock()
                tasks.append(task)
                lock.unlock()
            }
            
        } catch {
            print("\(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

