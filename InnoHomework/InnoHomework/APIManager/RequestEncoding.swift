//
//  RequestEncoding.swift
//  InnoTechHomework
//
//  Created by Derek_Lin on 2021/3/8.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

import Foundation

typealias Parameters = [String: Any]

protocol NetworkEndcoding {
    func encode(request: inout URLRequest, with parameters: Parameters?) throws
}

enum EncodingError: Error {
    case jsonEndcodingError
}

struct JSONEncoding: NetworkEndcoding {
    func encode(request: inout URLRequest, with parameters: Parameters?) throws {
        guard let parameters = parameters else { return }
        guard let data = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) else { throw EncodingError.jsonEndcodingError }
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = data
    }
}

struct URLEncoding: NetworkEndcoding {
    func encode(request: inout URLRequest, with parameters: Parameters?) throws {
        guard let parameters = parameters else { return }
        if let url = request.url {
            var urlComponent = URLComponents(string: "\(url)")
            let urlqueryItem = parameters.map { (key, value) in
                URLQueryItem(name: key, value: "\(value)")
            }
            urlComponent?.queryItems = urlqueryItem
            request.url = urlComponent?.url
        }
    }
}
