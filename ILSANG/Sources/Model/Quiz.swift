//
//  Quiz.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/18/24.
//

struct QuizResponse: Decodable {
    let quizId: Int
    let question: String
    let hint: String?
    
    enum CodingKeys: String, CodingKey {
        case quizId = "id"
        case question
        case hint
    }
}

struct ChallengeResponse: Decodable {
    let resultCode: String
}
