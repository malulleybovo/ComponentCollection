//
//  UUIDScannerViewController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 4/9/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import Vision
import VisionKit

@available(iOS 13.0, *)
class UUIDScannerViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openDocumentCamera()
    }
    
    private weak var documentCameraViewController: VNDocumentCameraViewController?
    
    func openDocumentCamera() {
        guard VNDocumentCameraViewController.isSupported else {
            let alert = UIAlertController(title: "This feature is not supported in this device.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        self.documentCameraViewController = documentCameraViewController
        present(documentCameraViewController, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        scan.fullText { scannedText in
            let uuidDetector = try? NSRegularExpression(pattern: "[0-9a-zA-Z]{8}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{12}", options: [])
            let uuid: String = uuidDetector?.matches(
                in: scannedText, options: [],
                range: NSRange(location: 0, length: scannedText.utf16.count))
                .compactMap({ match -> String? in
                    guard let range = Range(match.range, in: scannedText) else { return nil }
                    return String(scannedText[range])
                }).first ?? ""
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Please confirm the following information", message: "UUID: \(uuid)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                    controller.dismiss(animated: true)
                }))
                alert.addAction(UIAlertAction(title: "Retake", style: .destructive, handler: { _ in
                    controller.dismiss(animated: true)
                }))
                controller.present(alert, animated: true)
            }
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
}
