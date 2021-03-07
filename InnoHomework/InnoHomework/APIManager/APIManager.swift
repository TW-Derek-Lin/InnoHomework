//
//  APIManager.swift
//  InnoTechHomework
//
//  Created by Derek_Lin on 2021/3/8.
//  Copyright © 2021 Derek_Lin. All rights reserved.
//

import Foundation
import RxSwift

protocol Service {
    func retriveData<T: EndPoint>(from endPoint: T, completion: @escaping (Result<T.Element, Error>) -> Void)
}

class APIManager: Service {
    private let urlSession: URLSession

    init(_ configuratin: URLSessionConfiguration = .default) {
        self.urlSession = URLSession(configuration: configuratin)
    }

    func retriveData<T: EndPoint>(from endPoint: T, completion: @escaping (Result<T.Element, Error>) -> Void) {
        do {
            let request = try endPoint.makeRequest()
            let task = urlSession.dataTask(with: request) { data, response, error in
                let result = Result<T.Element, Error> {
                    try ErrorHandler.handling(with: error, response: response)
                    if let data = data {
                        return try JSONDecoder().decode(T.Element.self, from: data)
                    } else {
                        throw NetworkError.dataMissing
                    }
                }
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    struct ErrorHandler {
        static func handling(with error: Error?, response: URLResponse?) throws {
            if let error = error {
                switch (error as? URLError)?.code {
                case .some(.timedOut):
                    throw NetworkError.timeout
                case .some(.notConnectedToInternet), .some(.dataNotAllowed):
                    throw NetworkError.notReachable
                default:
                    throw error
                }
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkError.responseError
            }

            switch statusCode {
            case 200...299:
                break
            default:
                throw NetworkError.statusCodeError(statusCode)
            }
        }
    }
}
