//
//  SeasonTimerView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/24/25.
//

import SwiftUI
import Combine

struct SeasonTimerView: View {
    let season: Int
    let targetDate: Date

    @State private var now: Date = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(season: Int, targetDateString: String) {
        self.season = season
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        self.targetDate = formatter.date(from: targetDateString) ?? Date()
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text("시즌\(season) 종료까지")
                .styledFont(.subTitle1)
            Text(formattedRemainingTime)
                .styledFont(.title1)
                .monospacedDigit()
        }
        .foregroundStyle(.white)
        .frame(height: 86)
        .frame(maxWidth: .infinity)
        .roundedBackground(cornerRadius: 16, bgColor: .primaryPurple)
        .onReceive(timer) { input in
            now = input
        }
    }

    var formattedRemainingTime: String {
        let interval = now.distance(to: targetDate)
        guard interval > 0 else { return "0일 00:00:00" }

        let days = Int(interval) / (60 * 60 * 24)
        let hours = (Int(interval) / 3600) % 24
        let minutes = (Int(interval) / 60) % 60
        let seconds = Int(interval) % 60

        return String(format: "%d일 %02d:%02d:%02d", days, hours, minutes, seconds)
    }
}

#Preview {
    SeasonTimerView(season: 2, targetDateString: "2025-09-01")
}
