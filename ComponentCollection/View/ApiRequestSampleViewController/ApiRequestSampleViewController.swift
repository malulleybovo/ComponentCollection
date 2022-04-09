//
//  ApiRequestSampleViewController.swift
//  ComponentCollection
//
//  Created by malulleybovo on 4/9/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import Foundation
import UIKit

class ApiRequestSampleViewController: UIViewController {
    
    private let networkLayer = NetworkLayer()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let alert = UIAlertController(title: "Calling Mockup API using SampleService...", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.networkLayer.execute(request: SampleServiceRequest(body: SampleServiceBody(someId: 0))) { [weak self] statusCode, responseModel, message in
                let alertMessage: String
                if let responseModel = responseModel,
                   let data = responseModel.encode(),
                   let string = String(data: data, encoding: .utf8) {
                    alertMessage = "Status code: \(statusCode)\nResponseBody:\n\(string)"
                } else {
                    alertMessage = "Status code: \(statusCode)\nResponseBody:\nnil"
                }
                let alert = UIAlertController(title: "Mockup API Resoponse:", message: alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true)
            }
        }))
        present(alert, animated: true)
    }
    
}
