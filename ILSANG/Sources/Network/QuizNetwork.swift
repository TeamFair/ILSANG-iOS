//
//  QuizNetwork.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/26/24.
//

import Alamofire
import Foundation

// 퀘스트 미션의 랜덤 퀴즈 추출 API 요청
// 퀴즈 챌린지 저장 API 요청
final class QuizNetwork {
    private let url = APIManager.makeURL(CustomerTarget(path: ""))
    
    func getRandomQuiz(missionId: String) async -> Result<Response<Quiz>, Error> {
        return await Network.requestData(url: url+"mission/\(missionId)/quiz/random", method: .get, parameters: nil, withToken: true)
    }
    
    func postQuizChallenge(questId: String, quizId: String, answer: String) async -> Result<ResponseWithoutData, Error> {
        let bodyData: [String: Any] = [
            "questId": questId,
            "answers": [
                [
                    "quizId": quizId,
                    "answer": answer
                ]
            ]
        ]
        
        guard let jsonData = bodyData.convertToJsonData() else {
            return .failure(NetworkError.requestFailed("Fail to convert data"))
        }
        return await Network.requestData(url: url+"challenge/quiz", method: .post, parameters: nil, body: jsonData, withToken: true)
    }
}
