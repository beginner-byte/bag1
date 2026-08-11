//
//  UIFont+Extension.swift
//  NoaKit
//
//  Created by Candy on 2024/4/1.
//

import UIKit
extension UIFont {
    
    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: CGFloat.isSmallScreen ? size - 1 : size, weight: .medium)
    }
    
    static func regular(_ size: CGFloat) -> UIFont  {
        return UIFont.systemFont(ofSize: CGFloat.isSmallScreen ? size - 1 : size, weight: .regular)
    }
    
    static func semibold(_ size: CGFloat) -> UIFont  {
        return UIFont.systemFont(ofSize: CGFloat.isSmallScreen ? size - 1 : size, weight: .semibold)
    }
    
    static func light(_ size: CGFloat) -> UIFont  {
        return UIFont.systemFont(ofSize: CGFloat.isSmallScreen ? size - 1 : size, weight: .light)
    }
    
}
