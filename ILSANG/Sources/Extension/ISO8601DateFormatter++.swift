//
//  File.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/4/25.
//


import Foundation

extension ISO8601DateFormatter {
    static func dateOnlyString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 기준
        return formatter.string(from: date)
    }
}