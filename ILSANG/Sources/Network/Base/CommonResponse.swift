//
//  CommonResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/22/24.
//

import Alamofire

// TODO: 지역시스템 > 제거
struct Response<T: Decodable>: Decodable {
    let data: T
    let errorStatus: String?
    let errMessage: String?
    // let status, message: String?
    
    init(data: T, errorStatus: String?, errMessage: String?, status: String, message: String) {
        self.data = data
        self.errorStatus = errorStatus
        self.errMessage = errMessage
    }
}

struct ResponseWithPage<T> {
    let size: Int
    let content: T
    let totalPages: Int
    let totalElements: Int
    let page: Int
    let isLast: Bool
}

extension ResponseWithPage: Decodable where T: Decodable {}


struct ResponseWithoutData: Decodable {
    let data: [String: String]?
   
    init(data: [String: String]) {
        self.data = data
    }
}

/// 200번 코드에 서버 응답값이 없는 경우 사용
struct ResponseWithEmpty: Decodable, EmptyResponse {
    static func emptyValue() -> ResponseWithEmpty {
        return ResponseWithEmpty.init()
    }
}

struct ErrorResponse: Decodable {
    let message: String?
    let status: Int?
    let error: String?
}
