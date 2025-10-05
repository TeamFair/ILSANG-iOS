//
//  PostImageType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/5/25.
//


import Alamofire
import UIKit

enum PostImageType {
    case receipt
    case userProfileImage
    
    var parameter: String {
        switch self {
        case .receipt:
            return "RECEIPT"
        case .userProfileImage:
            return "USER_PROFILE_IMAGE"
        }
    }
}