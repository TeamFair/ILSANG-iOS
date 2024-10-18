//
//  XP.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/21/24.
//

import Foundation

struct XPModel: Decodable {
    let data: XP
}

struct XP: Decodable {
    let size: Int
    let data: [XPContent]
    let total: Int
    let page: Int
    let status: String
    let message: String
}

struct XPContent: Decodable {
    let recordId: Int
    let title: String
    let xpPoint: Int
    let createDate: String
    
    static let mockDataList = [
        XPContent(recordId: 1, title: "Mission Accomplished", xpPoint: 100, createDate: "2024-06-21"),
        XPContent(recordId: 2, title: "Daily Login", xpPoint: 50, createDate: "2024-06-22"),
        XPContent(recordId: 3, title: "Quest Completed", xpPoint: 150, createDate: "2024-06-23")
    ]
}
