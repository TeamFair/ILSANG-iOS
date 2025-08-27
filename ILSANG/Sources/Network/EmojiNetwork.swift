//
//  EmojiNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/16/24.
//

import Alamofire

final class EmojiNetwork {
    private let url: String = APIManager.makeURL(UserTarget(path: "mission", version: 1))
    
    func postEmoji(missionHistoryId: Int, emojiType: EmojiType) async -> Bool {
        let body = ["emojiType": emojiType.serverValue]
        let bodyData = body.convertToJsonData()
        let res: Result<ResponseWithEmpty, Error> = await Network.requestData(url: url+"/history/\(missionHistoryId)/emoji", method: .post, body: bodyData)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    func deleteEmoji(missionHistoryId: Int, emojiType: EmojiType) async -> Bool {
        let parameters: Parameters = ["emojiType": emojiType.serverValue]
        let res: Result<ResponseWithEmpty, Error> = await Network.requestData(url: url+"/history/\(missionHistoryId)/emoji", method: .delete, parameters: parameters)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

enum EmojiType: String, Decodable {
    case like = "LIKE"
    case hate = "HATE"
    
    var serverValue: String {
        rawValue.uppercased()
    }
}
