//
//  ImageNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/20/24.
//

import Alamofire
import UIKit

final class ImageNetwork {
    private let url = APIManager.makeURL(NoTarget(path: "image", version: 1))
    
    func getImage(imageId: String) async -> Result<UIImage, Error> {
        let parameters: Parameters = ["id": imageId]
        return await Network.requestImage(url: url, parameters: parameters, withToken: true)
    }
    
    func postImage(image: UIImage, type: PostImageType) async -> Result<ImageEntity, Error> {
        return await Network.postImage(url: url, image: image, withToken: true, type: type)
    }
    
    // TODO: 지역시스템 > 삭제/유지 결정 필요
    func deleteImage(imageId: String) async -> Bool {
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url, method: .delete, parameters: nil, withToken: true)
        switch res {
        case .success:
            Log(res)
            return true
        case .failure:
            Log(res)
            return false
        }
    }
}

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
