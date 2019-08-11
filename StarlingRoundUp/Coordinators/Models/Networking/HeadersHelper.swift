//
//  MergeHelper.swift
//  StarlingRoundUp
//
//  Created by Nikash Ramsorrun on 11/08/2019.
//  Copyright © 2019 Yogesh Nikash Ramsorrun. All rights reserved.
//

import Foundation

struct HeadersHelper {
    enum HeaderKeys: String {
        case accept = "Accept"
        case authorization = "Authorization"
    }
    
    let headers: [String: String]
    
    init(additionalHeaders: [String: String]? = nil) {
        headers = merge(HeadersHelper.getDefaultHeaders(), additionalHeaders) ?? HeadersHelper.getDefaultHeaders()
    }
    
    static func getDefaultHeaders() -> [String: String] {
        var headers = [String: String]()
        headers[HeaderKeys.accept.rawValue] = "application/json"
        headers[HeaderKeys.authorization.rawValue] = "Bearer Z96ivumkfpe9a9z2if3BNqWrnhdXTxiUwvFMm8DYnbcooU957YMCEqY55RkooStJ"
        return headers
    }
}

//Global Helper function
func merge(_ left: [String: String]?, _ right: [String: String]?) -> [String: String]? {
    if left == nil && right == nil { return nil }
    var mergedValues = left ?? [:]
    if let right = right {
        for (key, value) in right {
            mergedValues[key] = value
        }
    }
    return mergedValues
}
