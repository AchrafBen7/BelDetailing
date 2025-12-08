//
//  NetworkClientProtocol.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/12/2025.
//

import Foundation

protocol NetworkClientProtocol {
    func call<T: Decodable>(
        endPoint: APIEndPoint,
        dict: [String : Any?]?,
        urlDict: [String : Any?]?,
        additionalHeaders: [String : String]?,
        timeout: TimeInterval,
        allowAutoRefresh: Bool,
        wrappedInData: Bool
    ) async -> APIResponse<T>
}

extension NetworkClientProtocol {
    func call<T: Decodable>(
        endPoint: APIEndPoint,
        dict: [String : Any?]? = nil,
        urlDict: [String : Any?]? = nil,
        additionalHeaders: [String : String]? = nil,
        timeout: TimeInterval = 60,
        allowAutoRefresh: Bool = true,
        wrappedInData: Bool = false
    ) async -> APIResponse<T> {
        return await call(
            endPoint: endPoint,
            dict: dict,
            urlDict: urlDict,
            additionalHeaders: additionalHeaders,
            timeout: timeout,
            allowAutoRefresh: allowAutoRefresh,
            wrappedInData: wrappedInData
        )
    }
}
