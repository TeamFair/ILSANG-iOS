//
//  NetworkError.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/2/24.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidImageData
    case clientError(String)
    case serverError(String)
    case requestFailed(String)
    case unknownError
    case unknownStatusCode(Int)
    case emptyResponse
    case unauthorized
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            NSLocalizedString("유효하지 않은 URL입니다.", comment: "")
        case .invalidImageData:
            NSLocalizedString("이미지 데이터를 불러올 수 없습니다.", comment: "")
        case .clientError(let message):
            NSLocalizedString("클라이언트 오류가 발생했습니다: \(message)", comment: "")
        case .serverError(let message):
            NSLocalizedString("서버 오류가 발생했습니다: \(message)", comment: "")
        case .requestFailed(let message):
            NSLocalizedString("요청이 실패했습니다: \(message)", comment: "")
        case .unknownError:
            NSLocalizedString("알 수 없는 오류가 발생했습니다.", comment: "")
        case .unknownStatusCode(let statusCode):
            NSLocalizedString("알 수 없는 상태 코드입니다: \(statusCode)", comment: "")
        case .emptyResponse:
            NSLocalizedString("서버로부터 응답이 없습니다.", comment: "")
        case .unauthorized:
            NSLocalizedString("인증 정보가 유효하지 않습니다.", comment: "")
        }
    }
}
