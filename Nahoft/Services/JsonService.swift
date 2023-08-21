//
//  JsonService.swift
//  Nahoft
//
//  Created by Sadra Sadri on 8.08.2023.
//

import Foundation

class JsonService {
    static func toJson(data: [UInt8]) throws -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(data)
        return String(data: jsonData, encoding: .utf8)!
    }
    
    static func fromJson(str: String) throws -> [UInt8] {
        let jsonDecoder = JSONDecoder()
        let data = try jsonDecoder.decode([UInt8].self, from: (str.data(using: .utf8))!)
        return data
    }
}
