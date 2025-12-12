//
//  CommentRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

protocol CommentRepositoryInterface {
    func fetchComments(missionHistoryId: Int) async -> Result<[Comment], Error>
    func createComment(missionHistoryId: Int, parentId: Int?, comment: String) async -> Result<ResponseWithEmpty, Error>
    func reportComment(commentId: Int, reason: String) async -> Result<ResponseWithEmpty, Error>
    func deleteComment(commentId: Int) async -> Result<ResponseWithEmpty, Error>
}

final class CommentRepository: CommentRepositoryInterface {
    private let network: CommentNetwork
    
    init(network: CommentNetwork) {
        self.network = network
    }
    
    func fetchComments(missionHistoryId: Int) async -> Result<[Comment], Error> {
        let res = await network.fetchComments(missionHistoryId: missionHistoryId)
        return ResponseMapper.mapArrayResponse(res)
    }
    
    func createComment(missionHistoryId: Int, parentId: Int?, comment: String) async -> Result<ResponseWithEmpty, Error> {
        await network.createComment(missionHistoryId: missionHistoryId, parentId: parentId, comment: comment)
    }
    
    func reportComment(commentId: Int, reason: String) async -> Result<ResponseWithEmpty, any Error> {
        await network.reportComment(commentId: commentId, reason: reason)
    }
    
    func deleteComment(commentId: Int) async -> Result<ResponseWithEmpty, any Error> {
        await network.deleteComment(commentId: commentId)
    }
}
