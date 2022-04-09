//
//  VNDocumentCameraScan+Extension.swift
//  ComponentCollection
//
//  Created by malulleybovo on 4/9/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import Vision
import VisionKit

@available(iOS 13.0, *)
extension VNDocumentCameraScan {
    
    public final func everyTextPerPage(recognitionLevel: VNRequestTextRecognitionLevel = .accurate,
                                       recognitionLanguages: [String] = ["en-US"],
                                       dispatchQueue: DispatchQueue = DispatchQueue.global(qos: .default),
                                       completion: @escaping (_ everyTextPerPage: [[String]]) -> Void) {
        let scan = self
        dispatchQueue.async {
            let everyTextPerPage: [[String]] = (0..<scan.pageCount).compactMap({ index -> CGImage? in
                scan.imageOfPage(at: index).cgImage
            }).compactMap({ cgImage -> [String]? in
                let request = VNRecognizeTextRequest()
                request.recognitionLevel = recognitionLevel
                request.recognitionLanguages = recognitionLanguages
                request.usesLanguageCorrection = false
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try requestHandler.perform([request])
                } catch {
                    return nil
                }
                guard let observations = request.results else {
                    return nil
                }
                return observations.compactMap({
                    $0.topCandidates(1).first?.string
                })
            })
            completion(everyTextPerPage)
        }
    }
    
    public final func fullTextPerPage(recognitionLevel: VNRequestTextRecognitionLevel = .accurate,
                                      recognitionLanguages: [String] = ["en-US"],
                                      dispatchQueue: DispatchQueue = DispatchQueue.global(qos: .default),
                                      completion: @escaping (_ textPerPage: [String]) -> Void) {
        everyTextPerPage(recognitionLevel: recognitionLevel, recognitionLanguages: recognitionLanguages, dispatchQueue: dispatchQueue) { result in
            let textPerPage = result.map({ $0.joined(separator: "\n") })
            completion(textPerPage)
        }
    }
    
    public final func fullText(recognitionLevel: VNRequestTextRecognitionLevel = .accurate,
                               recognitionLanguages: [String] = ["en-US"],
                               dispatchQueue: DispatchQueue = DispatchQueue.global(qos: .default),
                               completion: @escaping (_ fullText: String) -> Void) {
        everyTextPerPage(recognitionLevel: recognitionLevel, recognitionLanguages: recognitionLanguages, dispatchQueue: dispatchQueue) { result in
            let fullText = result.map({ $0.joined(separator: "\n") }).joined(separator: "\n")
            completion(fullText)
        }
    }
    
}
