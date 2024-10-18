//
//  EmojiNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/16/24.
//

import Alamofire

final class EmojiNetwork {
    private let url: String
    
    init(url: String = APIManager.makeURL(CustomerTarget(path: "emoji"))) {
        self.url = url
    }
        
    func getEmoji(challengeId: String) async -> Result<Response<Emoji>,Error> {
        let parameters: Parameters = ["challengeId": challengeId]
        return await Network.requestData(url: url, method: .get, parameters: parameters, withToken: true)
    }
    
    func postEmoji(challengeId: String, emojiType: EmojiType) async -> Result<String, Error> {
        let body = ["targetId": challengeId,
                                "targetType": "challenge",
                                "emojiType": emojiType.rawValue]
        let bodyData = body.convertToJsonData()
        let res: Result<Response<EmojiResponseData>, Error> = await Network.requestData(url: url, method: .post, parameters: nil, body: bodyData, withToken: true)
        switch res {
        case .success(let model):
            return .success(model.data.emojiId)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteEmoji(emojiId: String) async -> Bool {
        let parameters: Parameters = ["emojiId": emojiId]
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url, method: .delete, parameters: parameters, withToken: true)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

enum EmojiType: String {
    case like
    case hate
}

fileprivate struct EmojiResponseData: Decodable {
    let emojiStatus: String
    let emojiId: String
}
