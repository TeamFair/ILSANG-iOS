//
//  QuizResponse.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/4/25.
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