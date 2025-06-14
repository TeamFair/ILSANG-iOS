//
//  NetworkError.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/2/24.
//

enum NetworkError: Error {
    case invalidURL
    case invalidImageData
    case clientError
    case serverError
    case requestFailed(String)
    case unknownError
    case unknownStatusCode(Int)
    case emptyResponse
    case unauthorized
}
