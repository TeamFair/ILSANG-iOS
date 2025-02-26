//
//  SubmitComponent.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/22/24.
//

import SwiftUI

// 제출 완료 상태 화면
struct SubmitCompleteView: View {
    let totalXP: Int
    let xpStats: [XpStat: Int]
    var action: () -> ()
    private let defaultSpacing: CGFloat = 16
    
    init(quest: QuestViewModelItem, action: @escaping ()->()) {
        self.totalXP = quest.totalRewardXP()
        self.xpStats  = quest.rewardDic
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: defaultSpacing) {
            Image(.arrowUpEffect)
                .resizable()
                .frame(width:58, height: 45)
                .padding(.bottom, -8)
            
            Text("\(totalXP)XP가 상승했어요")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.gray500)
            
            xpStatSummaryView(statValues: xpStats)
            
            PrimaryButton(title: "확인") {
                action()
            }
        }
        .padding(defaultSpacing)
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
        )
    }
    
    private func xpStatSummaryView(statValues: [XpStat: Int]) -> some View {
        let stats: [[XpStat]] = [[.strength, .intellect, .charm],
                                 [.fun, .sociability]]
        
        return VStack(spacing: 0) {
            ForEach(stats, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row, id: \.self) { stat in
                        xpStatItemView(icon: stat.image, point: statValues[stat])
                    }
                }
            }
        }
        .padding(8)
        .frame(width: 228, height: 76)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.background)
        )
    }
    
    private func xpStatItemView(icon: ImageResource, point: Int?) -> some View {
        HStack(spacing: 0) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 19, height: 19)
                .frame(width: 30, height: 30)
            
            Text("\(point ?? 0)P")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primaryPurple)
                        
            if let point = point, point > 0 {
                Image(.arrowUp)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 10)
                    .padding(.leading, 2)
            }
        }
        .padding(.horizontal, 2)
        .frame(height: 30)
    }
}

// 제출 진행 중 & 재시도 & 제출 실패 상태 화면
struct SubmitStatusView: View {
    let status: SubmitStatus
    var onConfirm: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Image(status.icon)
                .resizable()
                .scaledToFit()
                .frame(width: status.iconWidth)
                .padding(.bottom, 15)
            
            Text(status.title)
                .foregroundColor(.gray500)
                .font(.system(size: 17, weight: .bold))
                .padding(.bottom, 9)
            
            Text(status.subtitle)
                .foregroundColor(.gray400)
                .font(.system(size: 15, weight: .regular))
                .padding(.bottom, 4)
            
            if status != .inProgress {
                PrimaryButton(title: "확인") {
                    onConfirm()
                }
                .padding(16)
            }
        }
        .padding(.top, 30)
        .frame(width: 260, height: 240)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
        )
    }
}

enum SubmitStatus {
    case inProgress
    case complete
    case fail
    case retry
    
    var title: String {
        switch self {
        case .inProgress: "제출중이에요"
        case .complete: "제출이 완료됐어요"
        case .fail: "제출에 실패했어요"
        case .retry: "다시 한번 생각해 보세요!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .inProgress, .complete: ""
        case .fail: "다시 시도해보세요🥲"
        case .retry: "계속해서 도전할 수 있어요!"
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .inProgress: .ellipsisCircle
        case .complete: .check
        case .retry: .exclamationCircle
        case .fail: .xmarkCircle
        }
    }
    
    var iconWidth: CGFloat { 60.0 }
}

#Preview {
    ScrollView {
        SubmitStatusView(status: .inProgress, onConfirm: {})
        SubmitStatusView(status: .retry, onConfirm: {})
        SubmitStatusView(status: .fail, onConfirm: {})
        SubmitCompleteView(quest: .mockData, action: {})
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.secondary)
}
