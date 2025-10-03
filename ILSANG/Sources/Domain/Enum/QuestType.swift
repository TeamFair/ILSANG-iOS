//
//  QuestType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/21/25.
//


enum QuestType: String {
    case event
    case normal
    case `repeat`
    
    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "event":
            self = .event
        case "repeat":
            self = .repeat
        case "normal":
            self = .normal
        default:
            self = .normal
        }
    }
}
