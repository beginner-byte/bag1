//
//  UIButton+Extension.swift
//  NoaKit
//
//  Created by Candy on 2024/3/26.
//

import Foundation

extension UIButton {
    public func setBackgroundColor(_ colors: [UIColor], forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(colors.first?.cgColor ?? UIColor.black.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage1 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(colors.last?.cgColor ?? UIColor.black.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage2 = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image1 = colorImage1, let image2 = colorImage2 else {return}
        setTkThemeBackgroundImage([image1, image2], for: forState)
    }
    
    /// button init method
    /// - Parameters:
    ///   - title: btn 文字
    ///   - font: 文字字体
    ///   - color: 文字颜色
    ///   - imageName: btn image
    ///   - backImageName: btn back image
    ///   - backColor: btn back color
    ///   - backgroundColor: 背景颜色
    ///   - cornerRadius: 切圆角
    public convenience init(title: String, font: UIFont, colors: [UIColor], imageName: String? = nil, backImageName: String? = nil, backColors: [UIColor]? = nil, cornerRadius: CGFloat? = 0) {
        self.init()
        setTitle(title, for: .normal)
        setTkThemeTitleColor(colors, for: .normal)
        titleLabel?.font = font
        titleLabel?.lineBreakMode = .byClipping
        
        if let name = imageName{
            setImage(UIImage(named: name), for: .normal)
            setImage(UIImage(named: name), for: .highlighted)
        }
        if let name = backImageName{
            setBackgroundImage(UIImage(named: name), for: .normal)
            setBackgroundImage(UIImage(named: name), for: .highlighted)
        }
        if let colors = backColors {
            setBackgroundColor(colors, forState: .normal)
            setBackgroundColor(colors, forState: .highlighted)
        }
        
        if let radius = cornerRadius, radius > 0 {
            layer.masksToBounds = true
            layer.cornerRadius = radius
        }
    }
    
    @objc public func set(image anImage: UIImage?, title: String,
                   titlePosition: UIView.ContentMode, additionalSpacing: CGFloat, state: UIControl.State){
        self.imageView?.contentMode = .center
        self.setImage(anImage, for: state);
        
        positionLabelRespectToImage(title: title, position: titlePosition, spacing: additionalSpacing)
        
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
    }

    private func positionLabelRespectToImage(title: String, position: UIView.ContentMode,
                                             spacing: CGFloat) {
        let imageSize = self.imageRect(forContentRect: self.frame)
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(withAttributes: [kCTFontAttributeName as NSAttributedString.Key: titleFont!])
        
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
        
        switch (position){
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                       right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
    }
    

    @objc public func setTitlePosition(_ titlePosition: UIView.ContentMode, space: CGFloat) {
        
        layoutIfNeeded()

        var titleEdgeInsets = UIEdgeInsets.zero
        var imageEdgeInsets = UIEdgeInsets.zero
        
        guard let titleLabelSize = titleLabel?.intrinsicContentSize else {
            return
        }
        let titleLabelW = titleLabelSize.width
        let titleLabelH = titleLabelSize.height
        
        guard let imageViewSize = imageView?.bounds.size else {
            return
        }
        let imageViewW = imageViewSize.width
        let imageViewH = imageViewSize.height
        
        switch (titlePosition) {
        case .top:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageViewW, bottom: (imageViewH + space), right: 0)
            imageEdgeInsets = UIEdgeInsets(top: (titleLabelH + space), left: 0, bottom: 0, right: -titleLabelW)
                break;
        case .left:
            titleEdgeInsets = UIEdgeInsets(top: 0, left:  -imageViewW, bottom: 0, right: (imageViewW + space))
            imageEdgeInsets = UIEdgeInsets(top: 0, left: (titleLabelW + space), bottom: 0, right: -titleLabelW)
                break;
        case .bottom:
            titleEdgeInsets = UIEdgeInsets(top: (imageViewH + space), left: -imageViewW, bottom: 0, right: 0)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: (titleLabelH + space), right: -titleLabelW)
                break;
        case .right:
            titleEdgeInsets = UIEdgeInsets(top: 0, left: space, bottom: 0, right: -space)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -space, bottom: 0, right: space)
                break;
            default:
                break;
        }
        
        self.titleEdgeInsets = titleEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
}

/// 扩展button的点击区域
extension UIButton {
    private static var kExpandValue = "expandValue"
    public var expandValue: Double {
        set {
            objc_setAssociatedObject(self,&UIButton.kExpandValue,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self,&UIButton.kExpandValue) as? Double ?? 0.0
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let clickArea = CGRect(x: bounds.origin.x - expandValue, y: bounds.origin.y - expandValue, width: bounds.size.width + expandValue, height: bounds.size.height + expandValue)
        if clickArea.equalTo(bounds) {
            return super.point(inside: point, with: event)
        }
        return clickArea.contains(point)
    }
}
