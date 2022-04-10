//
//  UITappableLabelViewController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 4/9/22.
//

import UIKit

class UITappableLabelViewController: UIViewController {
    
    private lazy var label: UITappableLabel = {
        let v = UITappableLabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.numberOfLines = 0
        let a = NSMutableAttributedString()
        a.append(NSAttributedString(string: "Some static text followed by "))
        a.append(NSAttributedString(string: "some text that would open a link on a browser", attributes: [
            .foregroundColor: UIColor.systemBlue,
            .onTap: { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: "*opens link on browser*", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        ]))
        a.append(NSAttributedString(string: ". Another sentence of static text leading to the next paragraph.\n\nHEADER OF SECOND PARAGRAPH "))
        a.append(NSAttributedString(string: "\u{24D8}", attributes: [
            .foregroundColor: UIColor.systemBlue,
            .onTap: { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: "*just some information icon*", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        ]))
        a.append(NSAttributedString(string: "\n\nSecond paragraph containing a whole lot of static text and then giving users the choice to "))
        a.append(NSAttributedString(string: "open a new screen by tapping here", attributes: [
            .foregroundColor: UIColor.systemBlue,
            .onTap: { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: "*opens a screen in app*", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        ]))
        a.append(NSAttributedString(string: " or "))
        a.append(NSAttributedString(string: "increase the font size by a bit", attributes: [
            .foregroundColor: UIColor.systemBlue,
            .onTap: { [weak self] in
                guard let self = self else { return }
                self.label.font = UIFont.systemFont(ofSize: min(30, self.label.font.pointSize + 2))
            }
        ]))
        a.append(NSAttributedString(string: ".\n\n"))
        a.append(NSAttributedString(string: "LAST SENTENCE WITH A LINK BY ITSELF", attributes: [
            .foregroundColor: UIColor.systemBlue,
            .onTap: { [weak self] in
                guard let self = self else { return }
                let alert = UIAlertController(title: "*that's it*", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        ]))
        v.attributedText = a
        return v
    }()
    private func setupLabel() {
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
    }
    
}
