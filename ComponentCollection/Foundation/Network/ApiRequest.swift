//
//  ApiRequest.swift
//  ComponentCollection
//
//  Created by malulleybovo on 12/03/22.
//  Copyright © 2022 malulleybovo. All rights reserved.
//

import Foundation

class ApiRequest<M: Decodable> {
    var path: String { "" }
    var method: HttpMethod { .get }
    var parameters: ApiRequestParameters? { nil }
    var headers: [String : String]? { nil }
    var defaultMessage: String { "Oops, it seems something went wrong... please try again later." }
    final let mockupJsonFileName: String = "\(M.underlyingClass)"
    func parse(responseData: Data?) -> (responseModel: M?, apiMessage: String?) {
        var message: String?
        if let responseData = responseData,
           let responseDictionary = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String : Any],
           let apiMessage = (responseDictionary["message"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
           !apiMessage.isEmpty {
            message = apiMessage
        }
        return (responseModel: responseData?.decode(), apiMessage: message)
    }
}

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum ApiRequestParameters {
    case body(_: Encodable?)
    case url(parameters: [String: String]?)
}

extension Encodable {
    func encode() -> Data? {
        let encoder = JSONEncoder()
        if let type = underlyingClass as? CustomCodable.Type {
            encoder.dateEncodingStrategy = type.dateEncodingStrategy
            encoder.dataEncodingStrategy = type.dataEncodingStrategy
        }
        return try? encoder.encode(self)
    }
    
    var underlyingClass: Encodable.Type {
        var name = "\(type(of: self))"
        while name.starts(with: "Array<"), name.last == ">" {
            name = String(name.dropFirst(6).dropLast())
        }
        switch name {
        case "String": return String.self
        case "Date": return Date.self
        case "Int": return Int.self
        case "Int8": return UInt8.self
        case "Int16": return UInt16.self
        case "Int32": return UInt32.self
        case "Int64": return UInt64.self
        case "UInt": return UInt.self
        case "UInt8": return UInt8.self
        case "UInt16": return UInt16.self
        case "UInt32": return UInt32.self
        case "UInt64": return UInt64.self
        case "Double": return Double.self
        case "Float": return Float.self
        case "Data": return Data.self
        case "Bool": return Bool.self
        default: break
        }
        if let type = NSClassFromString(name) as? Encodable.Type {
            return type
        } else if var list = self as? [Encodable], !list.isEmpty {
            while !list.isEmpty, let a = list[0] as? [Encodable] {
                list = a
            }
            return type(of: list[0])
        } else {
            return type(of: self)
        }
    }
}

extension Decodable {
    static var underlyingClass: Decodable.Type {
        var name = "\(self)"
        var dummyJson: String?
        while name.starts(with: "Array<"), name.last == ">" {
            name = String(name.dropFirst(6).dropLast())
            dummyJson = "[\(dummyJson ?? "{}")]"
        }
        switch name {
        case "String": return String.self
        case "Date": return Date.self
        case "Int": return Int.self
        case "Int8": return UInt8.self
        case "Int16": return UInt16.self
        case "Int32": return UInt32.self
        case "Int64": return UInt64.self
        case "UInt": return UInt.self
        case "UInt8": return UInt8.self
        case "UInt16": return UInt16.self
        case "UInt32": return UInt32.self
        case "UInt64": return UInt64.self
        case "Double": return Double.self
        case "Float": return Float.self
        case "Data": return Data.self
        case "Bool": return Bool.self
        default: break
        }
        if let type = NSClassFromString(name) as? Decodable.Type {
            return type
        } else if let dummyJson = dummyJson,
                  let type = getUnderlyingStructType(dummyJson: dummyJson) {
            return type
        } else {
            return self
        }
    }
    static func getUnderlyingStructType(dummyJson: String) -> Decodable.Type? {
        guard let dummyJsonData = dummyJson.data(using: .utf8) else {
            return nil
        }
        do {
            let object = try JSONDecoder().decode(self, from: dummyJsonData)
            guard var list = object as? [Decodable], !list.isEmpty else {
                return nil
            }
            while !list.isEmpty, let a = list[0] as? [Decodable] {
                list = a
            }
            return type(of: list[0])
        } catch {
            switch error as? DecodingError {
            case .keyNotFound(let codingKey, _):
                if let index = dummyJson.lastIndex(of: "}") {
                    var dummyJson = dummyJson
                    dummyJson.insert(contentsOf: "\"\(codingKey.stringValue)\":null,", at: index)
                    return getUnderlyingStructType(dummyJson: dummyJson)
                }
                return nil
            case .valueNotFound(let type, _):
                let value: String
                if type is String.Type || type is Data.Type {
                    value = "\"\""
                } else if type is Int.Type || type is Double.Type || type is Float.Type || type is Date.Type || type is Int8.Type || type is Int16.Type || type is Int32.Type || type is Int64.Type || type is UInt.Type || type is UInt8.Type || type is UInt16.Type || type is UInt32.Type || type is UInt64.Type {
                    value = "0"
                } else if type is Bool.Type {
                    value = "true"
                } else {
                    return nil
                }
                guard dummyJson.contains("null") else {
                    return nil
                }
                return getUnderlyingStructType(dummyJson: dummyJson.replacingOccurrences(of: "null", with: value))
            default:
                return nil
            }
        }
    }
}

extension Data {
    func decode<T: Decodable>() -> T? {
        let decoder = JSONDecoder()
        if let type = T.underlyingClass as? CustomCodable.Type {
            decoder.dateDecodingStrategy = type.dateDecodingStrategy
            decoder.dataDecodingStrategy = type.dataDecodingStrategy
        }
        return try? decoder.decode(T.self, from: self)
    }
}

protocol CustomCodable: Codable {
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
    static var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { get }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    static var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { get }
}

extension CustomCodable {
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { .deferredToDate }
    static var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy { .base64 }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { .deferredToDate }
    static var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy { .base64 }
}

extension DateFormatter {
    convenience init(dateFormat: String, locale: Locale = .current) {
        self.init()
        self.dateFormat = dateFormat
        self.locale = locale
    }
}
