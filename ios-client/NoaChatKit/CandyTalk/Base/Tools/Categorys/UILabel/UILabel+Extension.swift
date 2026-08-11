//
//  UILabel+Extension.swift
//  NoaKit
//
//  Created by Candy on 2024/4/1.
//

import UIKit
extension UILabel {
    
    /// label 文字设置行高
    /// - Parameters:
    ///   - text: 文字
    ///   - lineHeight: 行高
    func setText(_ text: String, _ lineHeight: CGFloat){
        if text == "" || lineHeight <= font.lineHeight {
            attributedText = NSAttributedString(string: text)
            return
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight - font.lineHeight
        let attributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        attributedText = NSAttributedString(string: text, attributes: attributes)
        lineBreakMode = .byTruncatingTail
    }
    
    /// label init method
    /// - Parameters:
    ///   - text: 文字
    ///   - font: 字体
    ///   - color: 文字颜色
    ///   - align: 文字对齐方式
    ///   - numberOfLines: 行数
    ///   - backgroundColor: 背景颜色
    ///   - cornerRadius：圆角
    convenience init(text: String?, font: UIFont, colors: [UIColor], align: NSTextAlignment = .left, numberOfLines: Int = 1, backgroundColors: [UIColor]? = nil, cornerRadius: CGFloat? = 0) {
        self.init()
        self.text = text
        self.font = font
        self.tkThemetextColors = colors
        self.textAlignment = align
        self.numberOfLines = numberOfLines
        
        if let colors = backgroundColors {
            self.tkThemebackgroundColors = colors
        }
        
        if let radius = cornerRadius, radius > 0 {
            self.layer.masksToBounds = true
            self.layer.cornerRadius = radius
        }
    }
}
