//
//  NetworkLayer.swift
//  ComponentCollection
//
//  Created by malulleybovo on 13/03/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import Foundation

class NetworkLayer {
    
    /// Mockup implementation
    func execute<M: Decodable>(request: ApiRequest<M>, completion: @escaping (_ statusCode: Int, _ responseModel: M?, _ message: String) -> Void) {
        guard let pathToMockupFile = Bundle.main.path(forResource: request.mockupJsonFileName + ".mockup", ofType: "json"),
              let mockupJsonData = try? String(contentsOfFile: pathToMockupFile).data(using: .utf8),
              let mockupDictionary = try? JSONSerialization.jsonObject(with: mockupJsonData, options: []) as? [String : Any] else {
            completion(500, nil, request.defaultMessage)
            return
        }
        let mockupStatusCode = mockupDictionary["statusCode"] as? Int
        let mockupResponseData: Data?
        if let mockupResponseDictionary = mockupDictionary["response"] {
            mockupResponseData = try? JSONSerialization.data(withJSONObject: mockupResponseDictionary)
        } else {
            mockupResponseData = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let parsedMockupResponse = request.parse(responseData: mockupResponseData)
            let mockupMessage = parsedMockupResponse.apiMessage ?? request.defaultMessage
            completion(mockupStatusCode ?? 200, parsedMockupResponse.responseModel, mockupMessage)
        }
    }
    
}
