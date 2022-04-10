//
//  UILabelDescriptor.swift
//  ComponentCollection
//
//  Created by malulleybovo on 3/28/22.
//

import UIKit

open class UILabelDescriptor: UIViewDescriptor<UILabel> {
    
    public var text: String?
    public var attributedText: NSAttributedString?
    public var font: UIFont
    public var textColor: UIColor?
    public var numberOfLines: Int
    
    public init(text: String?, font: UIFont = .systemFont(ofSize: UIFont.systemFontSize), textColor: UIColor? = nil, numberOfLines: Int = 0) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        super.init()
    }
    
    public init(attributedText: NSAttributedString?, font: UIFont = .systemFont(ofSize: UIFont.systemFontSize), textColor: UIColor? = nil, numberOfLines: Int = 0) {
        self.attributedText = attributedText
        self.font = font
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        super.init()
    }
    
    public override func layout(view: UILabel) {
        view.font = font
        view.numberOfLines = numberOfLines
        view.textColor = textColor
        if attributedText != nil {
            view.attributedText = attributedText
        } else {
            view.text = text
        }
    }
    
}
