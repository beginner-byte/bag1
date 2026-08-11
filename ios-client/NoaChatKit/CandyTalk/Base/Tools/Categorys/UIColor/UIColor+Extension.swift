//
//  UIColor+Extension.swift
//  NoaKit
//
//  Created by Candy on 2024/4/1.
//

import UIKit
extension UIColor {
    
    /// Computed Properties
    public var toHex: String? {
        return toHex()
    }
    
    /// UIColor 便利构造方法
    /// - Parameters:
    ///   - hexString: 16进制色值字符串 RGB
    ///   - alpha: 透明度 取值范围 0 ~ 1
    public convenience init(_ hexString: String, _ alpha: CGFloat = 1) {
        
        var formatter = hexString
        if formatter.hasPrefix("0x") || formatter.hasPrefix("0X") {
            formatter = String(formatter[formatter.index(formatter.startIndex, offsetBy: 2)...])
        }
        if formatter.hasPrefix("#") {
            formatter = String(formatter[formatter.index(formatter.startIndex, offsetBy: 1)...])
        }

        guard let hex = Int(formatter, radix: 16) else {
            assert(false, "传入颜色值不合法")
            self.init()
            return
        }
        self.init(hex: hex, alpha: alpha)
    }
    
    /// UIColor 便利构造方法
    /// - Parameters:
    ///   - hex: 整型数字
    ///   - alpha: 透明度 取值范围 0 ~ 1
    public convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0x0000FF) >> 0) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// From UIColor to String
    public func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
