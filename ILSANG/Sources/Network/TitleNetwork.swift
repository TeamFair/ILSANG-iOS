//
//  TitleNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/13/25.
//

import Alamofire
import Foundation

protocol TitleNetworkInterface{
    func getTitles() async -> Result<[TitleResponse], Error>
    func getTitleHistories() async -> Result<[UserTitleResponse], Error>
    func getUnreadTitleHistories() async -> Result<[UserTitleResponse], Error>
    func readTitleHistory(historyId: Int) async -> Result<ResponseWithEmpty, Error>
}

struct MockTitleNetwork: TitleNetworkInterface {
    let userTitle = UserTitleResponse(titleHistoryId: 1, name: "김민준", grade: "12", type: "교내")
    
    func getTitles() async -> Result<[TitleResponse], Error> {
        .success([TitleResponse.mockStandard])
    }
    
    func getTitleHistories() async -> Result<[UserTitleResponse], any Error> {
        .success([userTitle])
    }
    
    func getUnreadTitleHistories() async -> Result<[UserTitleResponse], any Error> {
        .success([userTitle])
    }
    
    func readTitleHistory(historyId: Int) async -> Result<ResponseWithEmpty, any Error> {
        .success(.emptyValue())
    }
}

final class TitleNetwork: TitleNetworkInterface {
    private let url = APIManager.makeURL(NoTarget(path: "title", version: 1))
    private let userUrl = APIManager.makeURL(NoTarget(path: "user/title", version: 1))
    
    /// 칭호 전체 조회
    func getTitles() async -> Result<[TitleResponse], Error> {
        return await Network.requestData(url: url, method: .get)
    }
    
    /// 사용자 칭호 조회
    func getTitleHistories() async -> Result<[UserTitleResponse], Error> {
        return await Network.requestData(url: userUrl, method: .get)
    }
    
    /// 안읽은 사용자 칭호 조회
    func getUnreadTitleHistories() async -> Result<[UserTitleResponse], Error> {
        return await Network.requestData(url: userUrl+"/unread", method: .get)
    }
    
    /// 사용자 칭호 읽음 처리
    func readTitleHistory(historyId: Int) async -> Result<ResponseWithEmpty, Error> {
        return await Network.requestData(url: userUrl+"/\(historyId)/read", method: .put)
    }
    
    // TODO: API 추가시 스펙 대응
//    func getLegendRank(honorId: String) async -> Result<[HistoryRank], Error> {
//        let params = ["titleId": "\(honorId)"]
//        return await Network.requestData(url: url+"/rank", method: .get, parameters: params, withToken: true)
//    }
}
