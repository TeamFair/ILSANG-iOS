//
//  EmojiType.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/5/25.
//


import Alamofire

enum EmojiType: String, Decodable {
    case like = "LIKE"
    
    var serverValue: String {
        rawValue.uppercased()
    }
}
