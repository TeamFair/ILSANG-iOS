//
//  Quiz.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/18/24.
//

struct Quiz: Decodable {
    let quizId: Int
    let question, hint: String
    let answers: [Answer]
}

struct Answer: Decodable {
    let content: String
}
