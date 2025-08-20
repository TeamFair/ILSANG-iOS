//
//  EmojiNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/16/24.
//

import Alamofire

final class EmojiNetwork {
    private let url: String = APIManager.makeURL(UserTarget(path: "mission", version: 1))
        
    // TODO: 지역시스템 > 미사용 예정
    func getEmoji(missionHistoryId: Int) async -> Result<Response<Emoji>,Error> {
        let parameters: Parameters = ["missionHistoryId": missionHistoryId]
        return await Network.requestData(url: url, method: .get, parameters: parameters, withToken: true)
    }
    
    func postEmoji(missionHistoryId: Int, emojiType: EmojiType) async -> Result<String, Error> {
        let body = ["emojiType": emojiType.rawValue]
        let bodyData = body.convertToJsonData()
        let res: Result<Response<EmojiResponseData>, Error> = await Network.requestData(url: url+"/history/\(missionHistoryId)/emoji", method: .post, parameters: nil, body: bodyData, withToken: true)
        switch res {
        case .success(let model):
            return .success(model.data.emojiId)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // TODO: 파라미터 변경(임시상태)
    func deleteEmoji(emojiId missionHistoryId: String) async -> Bool {
        let parameters: Parameters = ["missionHistoryId": missionHistoryId]
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: url+"/history/\(missionHistoryId)/emoji", method: .delete, parameters: parameters, withToken: true)
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
