//
//  MissionType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


import UIKit

enum MissionType: Equatable, Hashable {
    case quiz(QuizType), photo
    
    init?(rawValue: String) {
        if let quizType = QuizType(rawValue: rawValue) {
            self = .quiz(quizType)
        } else if rawValue == "PHOTO" {
            self = .photo
        } else {
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .quiz(let quizType):
            quizType.description
        case .photo:
            "사진인증"
        }
    }
}
