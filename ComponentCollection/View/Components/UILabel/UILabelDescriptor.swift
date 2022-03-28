//
//  UILabelDescriptor.swift
//  ComponentCollection
//
//  Created by malulleybovo on 3/28/22.
//

import UIKit

class UILabelDescriptor: UIViewDescriptor<UILabel> {
    
    var text: String?
    var attributedText: NSAttributedString?
    var font: UIFont
    var textColor: UIColor?
    var numberOfLines: Int
    
    init(text: String?, font: UIFont = .systemFont(ofSize: UIFont.systemFontSize), textColor: UIColor? = nil, numberOfLines: Int = 0) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        super.init()
    }
    
    init(attributedText: NSAttributedString?, font: UIFont = .systemFont(ofSize: UIFont.systemFontSize), textColor: UIColor? = nil, numberOfLines: Int = 0) {
        self.attributedText = attributedText
        self.font = font
        self.textColor = textColor
        self.numberOfLines = numberOfLines
        super.init()
    }
    
    override func layout(view: UILabel) {
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
