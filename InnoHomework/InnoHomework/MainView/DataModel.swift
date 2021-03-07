//
//  DataModel.swift
//  InnoTechHomework
//
//  Created by Derek_Lin on 2021/3/8.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

import Foundation

struct DataModel: Codable {
    var albumId: Int?
    var id: Int?
    var title: String?
    var url: String?
    var thumbnailUrl: String?
}

struct PlaceholderEndpoint {
    typealias Element = [DataModel]
}
extension PlaceholderEndpoint: EndPoint, Encodable {
    var baseURL: String { "https://jsonplaceholder.typicode.com" }
    var path: String { "photos" }
    var httpMethod: HTTPMethod { .GET }
    var parameters: Parameters? { nil }
    var httpHeaders: HTTPHeaders? { nil }
}

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
