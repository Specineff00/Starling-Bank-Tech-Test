//
//  URLSession+Additions.swift
//  StackOverflow
//
//  Created by Yogesh N Ramsorrrun on 28/07/2019.
//  Copyright © 2019 Yogesh N Ramsorrrun. All rights reserved.
//

import Foundation

extension URLSession {
    func dataTask(withUrl url: URL,
                  headerFields: [String: String] = HeadersHelper.getDefaultHeaders(),
                  method: HTTPMethod = .get,
                  jsonData: Data? = nil,
                  result: @escaping CompletionClosure) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headerFields
        request.httpMethod = method.rawValue
        request.httpBody = jsonData

        return dataTask(with: request) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}
