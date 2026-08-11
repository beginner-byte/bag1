//
//  NoaGaOnchainManager.swift
//  GaOnchainLib
//
//  Created by phl on 2025/12/10.
//

import Foundation

// MARK: - 配置
@objc public class OCConfig: NSObject, Codable {
    @objc public let contractAddress: String
    @objc public let rpcNodes: [String]
    
    public init(contractAddress: String, rpcNodes: [String]) {
        self.contractAddress = contractAddress
        self.rpcNodes = rpcNodes
    }
}

// MARK: - 类型
@objc public enum NoaGaOnchainManagerErrorCode: Int {
    case configLoadFailed = 1000
    case invalidURL = 1001
    case encodingFailed = 1002
    case decodingFailed = 1003
    case rpcError = 1004
    case networkError = 1005
}

// MARK: - NoaGaOnchainManager 主类
@objc public class NoaGaOnchainManager: NSObject {
    
    /// 解密的key
    static let decodeKey = "ga.gw.cc"
    
    /// 网络请求
    private let session = URLSession.shared
    
    /// get(string) 的函数选择器
    private let GET_FUNCTION_SELECTOR = "0x693ec85e"
    
    /// 加载配置文件
    @objc public func loadConfig() throws -> OCConfig {
        // 从 Bundle 中获取 config.json 文件
        guard let bundleURL = Bundle(for: type(of: self)).url(forResource: "GaOnchainLib", withExtension: "bundle"),
              let resourceBundle = Bundle(url: bundleURL),
              let configURL = resourceBundle.url(forResource: "config", withExtension: "json") else {
            throw NSError(domain: "GaOnchainLib", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法找到 config.json 文件"])
        }
        
        let configData = try Data(contentsOf: configURL)
        return try JSONDecoder().decode(OCConfig.self, from: configData)
    }
    
    // MARK: 请求信息API
    
    /// 发起GaOnchain请求
    /// - Parameters:
    ///   - rpcUrl: RPC 节点 URL
    ///   - completion: 结果回调
    @objc public func getValue(
        rpcUrl: String,
        completion: @escaping (String?, Error?) -> Void
    ) {
        Task {
            do {
                let value = try await getValueAsync(rpcUrl: rpcUrl, key: NoaGaOnchainManager.decodeKey)
                completion(value, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    /// 发起GaOnchain请求，并返回可取消的网络请求Task
    /// - Parameters:
    /// - rpcUrl: RPC 节点 URL
    /// - completion: 完成回调
    /// - Returns: 可取消的 URLSessionDataTask
    @objc public func getValueWithTask(
        rpcUrl: String,
        completion: @escaping (String?, Error?) -> Void
    ) -> URLSessionDataTask? {
        return getValueTask(rpcUrl: rpcUrl, key: NoaGaOnchainManager.decodeKey) { result in
            switch result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // MARK: - GaOnchain请求具体实现
    
    /// 获取值并返回 task（不使用 async/await，直接返回 task）
    /// completion 只返回 String，task 通过方法返回值获取
    /// - Parameters:
    ///   - rpcUrl: RPC 节点 URL
    ///   - key: 解密的key
    ///   - completion: 完成回调(返回解密后的参数)
    /// - Returns: 可取消的 URLSessionDataTask
    private func getValueTask(
        rpcUrl: String,
        key: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> URLSessionDataTask? {
        do {
            let config = try loadConfig()
            
            // 编码函数调用数据
            let calldata = encodeGetCall(key: key)
            
            #if DEBUG
            print("调用合约 get 方法:")
            print("  合约地址: \(config.contractAddress)")
            print("  键: \(key)")
            print("  函数选择器: \(GET_FUNCTION_SELECTOR)")
            print("  编码数据 (calldata): \(calldata)")
            #endif
            
            // 构建 RPC 请求 JSON
            let requestDict: [String: Any] = [
                "jsonrpc": "2.0",
                "id": 1,
                "method": "eth_call",
                "params": [
                    [
                        "to": config.contractAddress,
                        "data": calldata
                    ],
                    "latest"
                ]
            ]
            
            #if DEBUG
            print("\n发送 RPC 请求到: \(rpcUrl)")
            #endif
            
            // 发送 HTTP 请求
            guard let url = URL(string: rpcUrl) else {
                let error = NSError(
                    domain: "NoaGaOnchainManagerError",
                    code: NoaGaOnchainManagerErrorCode.invalidURL.rawValue,
                    userInfo: [NSLocalizedDescriptionKey: "无效的 URL: \(rpcUrl)"]
                )
                completion(.failure(error))
                return nil
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestDict)
            
            // 创建 task，使用捕获列表来避免并发安全警告
            let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else {
                    return
                }
                
                // 处理网络错误
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // 检查数据是否存在
                guard let data = data else {
                    let error = NSError(
                        domain: "NoaGaOnchainManagerError",
                        code: NoaGaOnchainManagerErrorCode.networkError.rawValue,
                        userInfo: [NSLocalizedDescriptionKey: "没有收到响应数据"]
                    )
                    completion(.failure(error))
                    return
                }
                
                #if DEBUG
                print("RPC 响应: \(String(data: data, encoding: .utf8) ?? "")")
                #endif
                
                // 解析响应
                let jsonObject: Any
                do {
                    jsonObject = try JSONSerialization.jsonObject(with: data)
                } catch {
                    let error = NSError(
                        domain: "NoaGaOnchainManagerError",
                        code: NoaGaOnchainManagerErrorCode.decodingFailed.rawValue,
                        userInfo: [NSLocalizedDescriptionKey: "无法解析 RPC 响应: \(error.localizedDescription)"]
                    )
                    completion(.failure(error))
                    return
                }
                
                guard let responseDict = jsonObject as? [String: Any] else {
                    let error = NSError(
                        domain: "NoaGaOnchainManagerError",
                        code: NoaGaOnchainManagerErrorCode.decodingFailed.rawValue,
                        userInfo: [NSLocalizedDescriptionKey: "无法解析 RPC 响应"]
                    )
                    completion(.failure(error))
                    return
                }
                
                // 检查 RPC 错误
                if let error = responseDict["error"] as? [String: Any],
                   let code = error["code"] as? Int,
                   let message = error["message"] as? String {
                    let rpcError = NSError(
                        domain: "NoaGaOnchainManagerError",
                        code: NoaGaOnchainManagerErrorCode.rpcError.rawValue,
                        userInfo: [
                            NSLocalizedDescriptionKey: "RPC 错误: \(message)",
                            "rpcErrorCode": code
                        ]
                    )
                    completion(.failure(rpcError))
                    return
                }
                
                guard let result = responseDict["result"] as? String else {
                    let error = NSError(
                        domain: "NoaGaOnchainManagerError",
                        code: NoaGaOnchainManagerErrorCode.rpcError.rawValue,
                        userInfo: [NSLocalizedDescriptionKey: "响应中没有 result"]
                    )
                    completion(.failure(error))
                    return
                }
                
                #if DEBUG
                print("返回结果: \(result)")
                #endif
                
                // 解码返回结果
                do {
                    let value = try self.decodeString(result)
                    #if DEBUG
                    print("解码后的值: \(value)")
                    #endif
                    // 只返回 value，task 通过方法返回值获取
                    completion(.success(value))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
            return task
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    // MARK: - Internal Async Methods
    
    private func getValueAsync(rpcUrl: String, key: String) async throws -> String {
        let config = try loadConfig()
        
        // 编码函数调用数据
        let calldata = encodeGetCall(key: key)
        
        #if DEBUG
        print("调用合约 get 方法:")
        print("  合约地址: \(config.contractAddress)")
        print("  键: \(key)")
        print("  函数选择器: \(GET_FUNCTION_SELECTOR)")
        print("  编码数据 (calldata): \(calldata)")
        #endif
        
        // 构建 RPC 请求 JSON
        let requestDict: [String: Any] = [
            "jsonrpc": "2.0",
            "id": 1,
            "method": "eth_call",
            "params": [
                [
                    "to": config.contractAddress,
                    "data": calldata
                ],
                "latest"
            ]
        ]
        
        #if DEBUG
        print("\n发送 RPC 请求到: \(rpcUrl)")
        #endif
        
        // 发送 HTTP 请求
        guard let url = URL(string: rpcUrl) else {
            throw NSError(
                domain: "NoaGaOnchainManagerError",
                code: NoaGaOnchainManagerErrorCode.invalidURL.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "无效的 URL: \(rpcUrl)"]
            )
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestDict)
        
        let (data, _) = try await session.data(for: urlRequest)
        
        #if DEBUG
        print("RPC 响应: \(String(data: data, encoding: .utf8) ?? "")")
        #endif
        
        // 解析响应
        let jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data)
        } catch {
            throw NSError(
                domain: "NoaGaOnchainManagerError",
                code: NoaGaOnchainManagerErrorCode.decodingFailed.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "无法解析 RPC 响应: \(error.localizedDescription)"]
            )
        }
        
        guard let responseDict = jsonObject as? [String: Any] else {
            throw NSError(
                domain: "NoaGaOnchainManagerError",
                code: NoaGaOnchainManagerErrorCode.decodingFailed.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "无法解析 RPC 响应"]
            )
        }
        
        // 检查错误
        if let error = responseDict["error"] as? [String: Any],
           let code = error["code"] as? Int,
           let message = error["message"] as? String {
            throw NSError(
                domain: "NoaGaOnchainManagerError",
                code: NoaGaOnchainManagerErrorCode.rpcError.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: "RPC 错误: \(message)",
                    "rpcErrorCode": code
                ]
            )
        }
        
        guard let result = responseDict["result"] as? String else {
            throw NSError(
                domain: "NoaGaOnchainManagerError",
                code: NoaGaOnchainManagerErrorCode.rpcError.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "响应中没有 result"]
            )
        }
        
        #if DEBUG
        print("返回结果: \(result)")
        #endif
        
        // 解码返回结果
        let value = try decodeString(result)
        #if DEBUG
        print("解码后的值: \(value)")
        #endif
        
        return value
    }
    
    // MARK: - Private Helper Methods
    
    private func toHex32Bytes(_ value: Int) -> String {
        let hex = String(value, radix: 16)
        return "0x" + String(repeating: "0", count: max(0, 64 - hex.count)) + hex
    }
    
    private func encodeString(_ value: String) -> String {
        let utf8Data = value.data(using: .utf8)!
        let length = utf8Data.count
        
        let offset = toHex32Bytes(32).dropFirst(2)
        let lengthHex = toHex32Bytes(length).dropFirst(2)
        
        let dataHex = utf8Data.map { String(format: "%02x", $0) }.joined()
        let padding = (32 - (length % 32)) % 32
        let paddedDataHex = dataHex + String(repeating: "0", count: padding * 2)
        
        return String(offset) + String(lengthHex) + paddedDataHex
    }
    
    private func encodeGetCall(key: String) -> String {
        let selector = String(GET_FUNCTION_SELECTOR.dropFirst(2))
        let encodedParam = encodeString(key)
        return "0x" + selector + encodedParam
    }
    
    private func decodeString(_ data: String) throws -> String {
        let hex = data.hasPrefix("0x") ? String(data.dropFirst(2)) : data
        
        let offsetHex = String(hex.prefix(64))
        guard let offset = Int(offsetHex, radix: 16) else {
            throw NSError(
                domain: "NoaGaOnchainManagerError",
                code: NoaGaOnchainManagerErrorCode.decodingFailed.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "无法解析 offset"]
            )
        }
        
        let lengthStart = offset * 2
        let lengthHex = String(hex.dropFirst(lengthStart).prefix(64))
        guard let length = Int(lengthHex, radix: 16) else {
            throw NSError(
                domain: "NoaGaOnchainManagerError",
                code: NoaGaOnchainManagerErrorCode.decodingFailed.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "无法解析 length"]
            )
        }
        
        let dataStart = lengthStart + 64
        let dataHex = String(hex.dropFirst(dataStart).prefix(length * 2))
        
        var data = Data()
        var index = dataHex.startIndex
        while index < dataHex.endIndex {
            let nextIndex = dataHex.index(index, offsetBy: 2, limitedBy: dataHex.endIndex) ?? dataHex.endIndex
            let byteString = String(dataHex[index..<nextIndex])
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            }
            index = nextIndex
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw NSError(
                domain: "NoaGaOnchainManagerError",
                code: NoaGaOnchainManagerErrorCode.decodingFailed.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "无法将数据转换为字符串"]
            )
        }
        
        return string
    }
}

