//
//  ChallengeNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/26/24.
//

import Alamofire
import Foundation

// TODO: 지역시스템 >> mission history로 이동 필요, url 확인 필요
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
    
    func deleteChallenge(challengeId: String) async -> Bool {
        let deleteUrl = APIManager.makeURL(UserTarget(path: challengeId, version: 1))
        
        let res: Result<ResponseWithoutData, Error> = await Network.requestData(url: deleteUrl, method: .delete, parameters: nil, withToken: true)
        
        switch res {
        case .success:
            Log(res)
            return true
        case .failure:
            Log(res)
            return false
        }
    }
}
