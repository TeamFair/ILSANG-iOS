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
    func getLegendRank(titleId: String, page: Int, size: Int) async -> Result<ResponseWithPage<[LegendRankResponse]>, Error>
}

struct MockTitleNetwork: TitleNetworkInterface {
    let userTitle = UserTitleResponse(titleHistoryId: 1, name: "김민준", grade: "12", type: "교내", createdAt: "")
    
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
    
    func getLegendRank(titleId: String, page: Int, size: Int) async -> Result<ResponseWithPage<[LegendRankResponse]>, Error> {
        .success(.init(size: size, content: [], totalPages: 1, totalElements: 0, page: page, isLast: true))
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
    
    /// 전설 랭킹 조회
    func getLegendRank(titleId: String, page: Int, size: Int) async -> Result<ResponseWithPage<[LegendRankResponse]>, Error> {
        let params = ["titleId": "\(titleId)", "page": "\(page)", "size": "\(size)"]
        return await Network.requestData(url: userUrl+"/legend", method: .get, parameters: params)
    }
}
