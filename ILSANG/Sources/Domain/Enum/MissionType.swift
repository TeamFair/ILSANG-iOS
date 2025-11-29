//
//  MissionType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


import UIKit

enum MissionType: Equatable, Hashable, SelectableTabItem {
    case quiz(QuizType), photo
    
    var id: String { self.description }
    static var allCases: [MissionType] = [.photo, .quiz(.ox), .quiz(.text)]
    
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
    
    var headerText: String {
        self.description
    }
    
    var parameterText: String {
        switch self {
        case .quiz(let quizType):
            switch quizType {
            case .text:
                "WORDS"
            case .ox:
                "OX"
            }
        case .photo:
            "PHOTO"
        }
    }
}
