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
