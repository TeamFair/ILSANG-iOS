//
//  ChallengeNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/26/24.
//

import Alamofire

final class ChallengeNetwork {
    private let url: String = APIManager.makeURL(NoTarget(path: "challenge", version: 1))
    
    func getRandomQuiz(missionId: Int) async -> Result<QuizResponse, Error> {
        let parameters: Parameters = ["missionId": "\(missionId)"]
        return await Network.requestData(url: url+"/random-quiz", method: .get, parameters: parameters)
    }
    
    func postQuizChallenge(missionId: Int, quizId: Int, answer: String) async -> Result<ChallengeResponse, Error> {
        let bodyData: [String: Any] = [
            "missionId": "\(missionId)",
            "quizId": "\(quizId)",
            "answer": answer
        ]
        return await postChallenge(body: bodyData)
    }
    
    func postPhotoChallenge(missionId: Int, imageId: String) async -> Result<ChallengeResponse, Error> {
        let bodyData: [String: Any] = [
            "missionId": "\(missionId)",
            "imageId": imageId
        ]
        return await postChallenge(body: bodyData)
    }
    
    private func postChallenge(body: [String: Any]) async -> Result<ChallengeResponse,Error> {
        guard let bodyData = body.convertToJsonData() else {
            return .failure(NetworkError.requestFailed("Fail to convert data"))
        }
        return await Network.requestData(url: url+"/mission", method: .post, body: bodyData)
    }
}
