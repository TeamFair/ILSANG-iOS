//
//  CommentNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

import Alamofire

final class CommentNetwork {
    private let url: String = APIManager.makeURL(UserTarget(path: "mission", version: 1))
    
    // 댓글 조회
    func fetchComments(missionHistoryId: Int) async -> Result<[CommentResponse], Error> {
        let parameters: Parameters = ["missionHistoryId": missionHistoryId]
        return await Network.requestData(url: url+"/history/comment", method: .get, parameters: parameters)
    }
    
    // 댓글 생성
    func createComment(missionHistoryId: Int, parentId: Int?, comment: String) async -> Result<ResponseWithEmpty, Error> {
        var body: [String: Any] = ["comment": comment]
        if let parentId {
            body["parentId"] = parentId
        }
        guard let bodyData = body.convertToJsonData() else {
            return .failure(NetworkError.requestFailed("Fail to convert data"))
        }
        return await Network.requestData(url: url+"/history/comment/\(missionHistoryId)", method: .post, body: bodyData)
    }
    
    // 댓글 신고
    func reportComment(commentId: Int, reason: String) async -> Result<ResultCodeResponse, Error> {
        let body: [String: Any] = ["reason": reason]
        guard let bodyData = body.convertToJsonData() else {
            return .failure(NetworkError.requestFailed("Fail to convert data"))
        }
        return await Network.requestData(url: url+"/history/comment/\(commentId)/report", method: .post, body: bodyData)
    }
    
    // 댓글 삭제
    func deleteComment(commentId: Int) async -> Result<ResponseWithEmpty, Error> {
        return await Network.requestData(url: url+"/history/comment/\(commentId)", method: .delete)
    }
}
