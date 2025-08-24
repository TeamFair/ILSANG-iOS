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
// TODO: 지역시스템 > url 및 메서드 확인 필요
final class QuizNetwork {
    private let url = APIManager.makeURL(NoTarget(path: "", version: 1))
    
    func getRandomQuiz(missionId: Int) async -> Result<Response<Quiz>, Error> {
        return await Network.requestData(url: url+"mission/\(missionId)/quiz/random", method: .get, parameters: nil, withToken: true)
    }
}
