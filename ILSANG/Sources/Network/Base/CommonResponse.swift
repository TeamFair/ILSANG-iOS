//
//  CommonResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/22/24.
//

import Alamofire

struct Response<T: Decodable>: Decodable {
    let data: T
    let errorStatus: String?
    let errMessage: String?
    let status, message: String
    
    init(data: T, errorStatus: String?, errMessage: String?, status: String, message: String) {
        self.data = data
        self.errorStatus = errorStatus
        self.errMessage = errMessage
        self.status = status
        self.message = message
    }
}

struct ResponseWithPage<T: Decodable>: Decodable {
    let size: Int
    let data: T
    let total: Int
    let page: Int
    let status: String
    let message: String
}

struct ResponseWithoutData: Decodable {
    let data: [String: String]?
    let errorStatus: String?
    let errMessage: String?
    let status: String
    let message: String
    
    init(data: [String: String], errorStatus: String?, errMessage: String?, status: String, message: String) {
        self.data = data
        self.errorStatus = errorStatus
        self.errMessage = errMessage
        self.status = status
        self.message = message
    }
}

/// 200번 코드에 서버 응답값이 없는 경우 사용
struct ResponseWithEmpty: Decodable, EmptyResponse {
    static func emptyValue() -> ResponseWithEmpty {
        return ResponseWithEmpty.init()
    }
}

struct ErrorResponse: Decodable {
    let errMessage: String?
    let status: String?
    let message: String?
}
