//
//  SampleService.swift
//  ComponentCollection
//
//  Created by malulleybovo on 13/03/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import Foundation

struct SampleServiceBody: Codable {
    var someId: Int?
}

class SampleServiceResponse: Codable {
    var someString: String
    var someDouble: Double
    var someBool: Bool
    let someDate: Date
}

class SampleServiceRequest: ApiRequest<[SampleServiceResponse]> {
    override var path: String { "path/to/endpoint" }
    override var method: HttpMethod { .post }
    override var parameters: ApiRequestParameters? { .body(body) }
    
    let body: SampleServiceBody
    
    init(body: SampleServiceBody) {
        self.body = body
    }
}
