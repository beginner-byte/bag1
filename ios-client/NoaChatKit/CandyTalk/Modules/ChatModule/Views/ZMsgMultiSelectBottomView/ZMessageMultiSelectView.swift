//
//  NoaMessageMultiSelectView.swift
//  NoaKit
//
//  Created by Candy on 2024/4/1.
//

import UIKit
import SnapKit
@objc class ZMessageMultiSelectView: UIView {

    @objc var selectCallback: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectEvent() {
        guard let selectCallback = selectCallback else {return}
        selectCallback()
    }
    
    func setupUI() {
        let line = UIView()
        line.tkThemebackgroundColors = [UIColor("#D0D3D5"),UIColor("#D0D3D5")]
        
        let contentView = UIView()
        contentView.tkThemebackgroundColors = [UIColor("ffffff"), UIColor("ffffff")]
        contentView.layer.tkThemeborderColors = [UIColor("#D0D3D5"),UIColor("#D0D3D5")]
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectEvent)))
        
        let selectLabel = UILabel(text: NoaLanguageManager.share().matchLocalLanguage("选择以下消息"), font: .regular(14),colors: [UIColor("333333"),UIColor("333333")])
        
        addSubview(line)
        addSubview(contentView)
        contentView.addSubview(selectLabel)
        
        line.snp.makeConstraints { make in
            make.leading.equalTo(CGFloat.DWScale(16))
            make.trailing.equalTo(CGFloat.DWScale(-16))
            make.centerY.equalTo(self)
            make.height.equalTo(CGFloat.DWScale(1))
        }
        
        contentView.snp.makeConstraints { make in
            make.leading.equalTo(CGFloat.DWScale(36))
            make.centerY.equalTo(self)
            make.height.equalTo(CGFloat.DWScale(24))
        }
        
        selectLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: .DWScale(2), left: .DWScale(10), bottom: .DWScale(2), right: .DWScale(10)))
        }
    }
    
    
}
