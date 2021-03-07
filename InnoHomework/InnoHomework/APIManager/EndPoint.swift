//
//  EndPoint.swift
//  InnoTechHomework
//
//  Created by Derek_Lin on 2021/3/8.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String: String]

enum NetworkError: Error {
    case responseError, statusCodeError(Int), urlMissing, dataMissing, timeout, notReachable
    var description: String {
        switch self {
        case .responseError:
            return "API response error"
        case .statusCodeError(let status):
            return "Status code \(status) error"
        case .urlMissing:
            return "Illegal url string"
        case .dataMissing:
            return "Response no data"
        case .timeout:
            return "request timeout"
        case .notReachable:
            return "Network not reachable"
        }
    }
}

enum HTTPMethod: String {
    case POST, GET
}

protocol EndPoint {
    associatedtype Element: Codable
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var parameters: Parameters? { get }
    var httpHeaders: HTTPHeaders? { get }

    var encoder: NetworkEndcoding { get }
    func makeRequest() throws -> URLRequest
}

extension EndPoint {
    var encoder: NetworkEndcoding {
        switch self.httpMethod {
        case .GET:
            return URLEncoding()
        case .POST:
            return JSONEncoding()
        }
    }

    func makeRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL)?.appendingPathComponent(path) else {
            throw NetworkError.urlMissing
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        httpHeaders?.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        var newParameter: Parameters = [:]
        if let parameter = self.parameters {
            newParameter = parameter
        }
        do {
            try encoder.encode(request: &request, with: newParameter)
            return request
        } catch {
            throw error
        }
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    var json: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
