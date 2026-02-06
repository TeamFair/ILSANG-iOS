//
//  CommentRepository.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/12/25.
//

protocol CommentRepositoryInterface {
    func fetchComments(missionHistoryId: Int) async -> Result<[Comment], Error>
    func createComment(missionHistoryId: Int, parentId: Int?, comment: String) async -> Result<ResponseWithEmpty, Error>
    func reportComment(commentId: Int, reason: String) async throws
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
    
    func reportComment(commentId: Int, reason: String) async throws {
        let response = try await network
            .reportComment(commentId: commentId, reason: reason)
            .get()

        switch response.resultCode {
        case "S1000": // 신고 성공
            return
        case "R1000": // 이미 신고한 케이스
            throw ReportError.alreadyReported
        default:
            throw ReportError.unknown(code: response.resultCode)
        }
    }
    
    func deleteComment(commentId: Int) async -> Result<ResponseWithEmpty, any Error> {
        await network.deleteComment(commentId: commentId)
    }
}

enum ReportError: Error, Equatable {
    case alreadyReported
    case unknown(code: String)
}
