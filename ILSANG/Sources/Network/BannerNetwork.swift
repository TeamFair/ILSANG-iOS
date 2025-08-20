//
//  BannerNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/23/25.
//

import Alamofire
import Foundation

final class BannerNetwork {
    private let url = APIManager.makeURL(NoTarget(path: "v1/banner", version: 1))
    
    func getMainBanners() async -> Result<ResponseWithPage<[BannerEntity]>, Error> {
        let parameters: Parameters = ["page": 0, "size" : 10, "titleLike": "", "descriptionLike": "", "activeYn": "Y"]
        return await Network.requestData(url: url, method: .get, parameters: parameters, withToken: false)
    }
}
