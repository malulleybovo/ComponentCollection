//
//  UITappableLabel.swift
//  ComponentCollection
//
//  Created by malulleybovo on 4/9/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import UIKit

open class UITappableLabel: UILabel {
    
    private let layoutManager = NSLayoutManager()
    private let textContainer = NSTextContainer(size: .zero)
    private lazy var textStorage = NSTextStorage(attributedString: NSAttributedString())
    
    public var highlightsTappableContent: Bool = true {
        didSet {
            if !highlightsTappableContent {
                highlighter.forEach({ $0.removeFromSuperview() })
            }
        }
    }
    public var highlighterColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.35) {
        didSet {
            for item in highlighter {
                item.backgroundColor = highlighterColor
            }
        }
    }
    
    public override var lineBreakMode: NSLineBreakMode {
        didSet {
            textContainer.lineBreakMode = lineBreakMode
        }
    }
    public override var numberOfLines: Int {
        didSet {
            textContainer.maximumNumberOfLines = numberOfLines
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        font = UIFont.systemFont(ofSize: 16)
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(sender:))))
    }
    @objc private func tapped(sender: UITapGestureRecognizer) {
        guard let attributedText = attributedText, let font = font else { return }
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        mutable.enumerateAttributes(
            in: NSRange(location: 0, length: attributedText.length),
            options: []) { attributes, range, stop in
                if !(attributes[.font] is UIFont) {
                    mutable.addAttribute(.font, value: font, range: range)
                }
        }
        textStorage.setAttributedString(mutable)
        textContainer.size = bounds.size
        let location = sender.location(in: self)
        let size = bounds.size
        let boundingBox = layoutManager.usedRect(for: textContainer)
        let offset = CGPoint(
            x: (size.width - boundingBox.size.width) * 0.5 - boundingBox.origin.x,
            y: (size.height - boundingBox.size.height) * 0.5 - boundingBox.origin.y)
        let tappableLocation = CGPoint(
            x: location.x - offset.x,
            y: location.y - offset.y)
        let index = layoutManager.characterIndex(
            for: tappableLocation,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil)
        var detected: (range: NSRange, onTap: () -> Void)?
        attributedText.enumerateAttributes(
            in: NSRange(location: 0, length: attributedText.length),
            options: []) { attributes, range, stop in
                guard detected == nil, let onTap = attributes[.onTap] as? () -> Void else { return }
                if NSLocationInRange(index, range) {
                    detected = (range: range, onTap: onTap)
                }
        }
        highlighter.forEach({ $0.removeFromSuperview() })
        if let detected = detected {
            highlight(range: detected.range)
            layoutSubviews()
            detected.onTap()
        }
    }
    
    private var highlighter: [UIView] = []
    private func newHighlighter() -> UIView {
        let v = UIView(frame: .zero)
        v.backgroundColor = highlighterColor
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 8
        return v
    }
    private func highlight(range: NSRange) {
        guard highlightsTappableContent else { return }
        let start = range.lowerBound
        let end = range.upperBound
        var boundingBoxes: [CGRect] = []
        var boundingBox = CGRect()
        var origin = CGPoint()
        for index in start..<end {
            let partialBoundingBox = layoutManager.boundingRect(forGlyphRange: NSRange(index..<(index + 1)), in: textContainer)
            if index == start {
                boundingBox = partialBoundingBox
                origin = boundingBox.origin
            } else if origin.x < partialBoundingBox.origin.x {
                boundingBox = boundingBox.union(partialBoundingBox)
            } else {
                boundingBoxes.append(boundingBox)
                boundingBox = partialBoundingBox
                origin = boundingBox.origin
            }
        }
        boundingBoxes.append(boundingBox)
        while highlighter.count < boundingBoxes.count {
            highlighter.append(newHighlighter())
        }
        let px = font.pointSize / 4
        let py = font.pointSize / 8
        for (index, boundingBox) in boundingBoxes.enumerated() {
            let highlighter = highlighter[index]
            addSubview(highlighter)
            highlighter.alpha = 1
            highlighter.frame = boundingBox
                .inset(by: UIEdgeInsets(top: -py, left: -px, bottom: -py, right: -px))
            UIView.animate(withDuration: 0.5) {
                highlighter.alpha = 0
            } completion: { _ in
                highlighter.removeFromSuperview()
            }

        }
    }
    
}

extension NSAttributedString.Key {
    public static let onTap: NSAttributedString.Key = .init("onTap")
}

open class UITappableLabelDescriptor: UIViewDescriptor<UITappableLabel> {
    
    public var attributedText: NSAttributedString?
    public var font: UIFont
    public var textColor: UIColor?
    public var numberOfLines: Int
    
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
        view.attributedText = attributedText
    }
    
}
