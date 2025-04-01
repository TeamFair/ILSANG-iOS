//
//  String++.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/7/24.
//

import Foundation

extension String {
    /// ISO 8601 형식의 문자열을 Date로 변환
    func toDate() -> Date? {
        // formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return dateFormatter.date(from: self)
    }

    /// 서버에서 보내주는 시간을 "12월 31일" 형식으로 날짜 포맷 변환.
    /// 현재와 년도가 다를 경우 "2024년 12월 31일"로 변환.
    ///
    /// 서버 응답 예시들: 3125-01-02T00:00:00, 2024-07-04T00:31:57.313048
    func timeAgoSinceDate(withYear: Bool = true) -> String {
        let date = self.split(separator: ".")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let date = dateFormatter.date(from: String(date[0])) else { return "" }
        // 현재 년도 구하기
        let currentYear = Calendar.current.component(.year, from: Date())
        let dateYear = Calendar.current.component(.year, from: date)
        
        // 날짜 포맷 설정
        let dateFormat = withYear ? (currentYear != dateYear ? "yyyy년 M월 d일" : "M월 d일") : "M월 d일"
        
        // 설정한 포맷으로 변환
        dateFormatter.dateFormat = dateFormat
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate
    }
    
    /// 서버에서 보내주는 시간을 "2024.12.31" 형식으로 날짜 포맷 변환.
    /// 현재와 년도가 다를 경우 "2024.12.31"로 변환.
    func timeAgoCreatedAt() -> String {
            // 날짜 문자열을 "."로 분리하여 첫 번째 부분 사용
            let dateComponents = self.split(separator: ".")
            
            // DateFormatter 설정
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            // 문자열을 Date 객체로 변환
            guard let date = dateFormatter.date(from: String(dateComponents[0])) else { return "" }
            
            // 현재 연도와 날짜의 연도 비교
            let currentYear = Calendar.current.component(.year, from: Date())
            let dateYear = Calendar.current.component(.year, from: date)
            
            // 날짜 포맷 설정
            var dateFormat = "yyyy.MM.dd"
            if currentYear != dateYear {
                dateFormat = "yyyy.MM.dd"
            }
            
            // 설정한 포맷으로 변환
            dateFormatter.dateFormat = dateFormat
            let formattedDate = dateFormatter.string(from: date)
            
            return formattedDate
        }
    
    /// 서버에서 보내주는 시간 "2024-08-07 18:31:49" 을 "2024.12.31" 형식으로 날짜 포맷 변환.
    /// 현재와 년도가 다를 경우 "2024.12.31"로 변환.
    func timeAgoSinceCreation() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.date(from: self) else { return "" }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"
        let formattedDate = outputFormatter.string(from: date)
        
        return formattedDate
    }
    
    /// 서버에서 보내주는 값을 1,000 형태로 포맷 변경
    /// 천의 자리 배수에 ","을 추가합니다. "1,000,000" 형식
    func formatNumberInText() -> String {
        guard let num = Int(self) else { return self }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: num)) ?? ""
    }
    
    /// 텍스트가 임의로 줄바꿈 되는 현상을 방지하기 위한 프로퍼티
    var forceCharWrapping: Self {
        self.map({ String($0) }).joined(separator: "\u{200B}") /// 200B: 가로폭 없는 공백문자
    }
}
