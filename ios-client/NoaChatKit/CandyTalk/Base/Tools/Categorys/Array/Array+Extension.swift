//
//  Array+Extension.swift
//  NoaKit
//
//  Created by Candy on 2024/3/26.
//

import Foundation

extension Array {
    /// 简单实现数组切片
    subscript(i1: Int, i2: Int, rest: Int...) -> [Element] {
        get {
            var result: [Element] = [self[i1], self[i2]]
            for index in rest {
                result.append(self[index])
            }
            return result
        }
        
        set (values) {
            for (index, value) in zip([i1, i2] + rest, values) {
                self[index] = value
            }
        }
    }
    
    /// 数组安全下标
    subscript (safe index: Index) -> Element? {
        guard index >= 0 && index < self.count else {
            return nil
        }
        return self[index]
    }
}
