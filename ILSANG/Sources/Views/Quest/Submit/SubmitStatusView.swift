//
//  SubmitComponent.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/22/24.
//

import SwiftUI

struct SubmitCompleteView: View {
    let totalXP: Int
    let xpStats: [XpStat: Int]
    var action: () -> ()
    
    init(quest: QuestViewModelItem, action: @escaping ()->()) {
        self.totalXP = quest.totalRewardXP()
        self.xpStats  = quest.rewardDic
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image(.arrowUpEffect)
                .resizable()
                .frame(width:58, height: 45)
                .padding(.bottom, 8)
            
            Text("\(totalXP)XP가 상승했어요")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.gray500)
                .padding(.bottom, 12)
            
            xpStatStatusView(stats: xpStats)
                .padding(.bottom, 12)
            
            PrimaryButton(title: "확인") {
                action()
            }
            .padding(.horizontal ,16)
        }
        .padding(.vertical, 16)
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.white)
        )
    }
    
    private func xpStatStatusView(stats: [XpStat: Int]) -> some View {
        let stats: [[XpStat]] = [[.strength, .intellect, .charm],
                                 [.fun, .sociability]]
        
        return VStack(spacing: 6) {
            ForEach(stats, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { stat in
                        xpStatItemView(image: stat.image, value: xpStats[stat])
                    }
                }
            }
        }
        .padding(4)
        .frame(width: 200, height: 40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.background)
        )
    }
    
    private func xpStatItemView(image: ImageResource, value: Int?) -> some View {
        HStack(spacing: 0) {
            Image(image)
                .resizable()
                .frame(width: 12, height: 12)
                .scaledToFit()
            
            Text("\(value ?? 0)P")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.primaryPurple)
                .frame(width: 30, height: 14)
            
            Spacer(minLength: 0)
            
            if let value = value, value > 0 {
                Image(.arrowUp)
            }
        }
        .padding(.horizontal, 2)
        .frame(width: 52, height: 14)
    }
}

struct SubmitStatusView: View {
    let status: SubmitStatus
    var onConfirm: () -> ()
    
    var body: some View {
        
        VStack(spacing: 0) {
            IconView(iconWidth: status.iconWidth, size: .medium, icon: status.icon, color: status.color)
                .padding(.bottom, 15)
            
            Text(status.title)
                .foregroundColor(.gray500)
                .font(.system(size: 17, weight: .bold))
                .padding(.bottom, 9)
            
            HStack(spacing: 0) {
                Text(status.subtitle)
                    .foregroundColor(.gray400)
                    .font(.system(size: 15, weight: .regular))
                Text(status.emoticon)
                    .font(.system(size: 12))
            }
            .padding(.bottom, 4)
            
            PrimaryButton(title: "확인") {
                onConfirm()
            }
            .padding(16)
            .opacity(status == .submit ? 0 : 1)
        }
        .padding(.top, status == .submit ? 90 : 30)
        .frame(width: 260, height: 240)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
        )
    }
}

enum SubmitStatus {
    case submit
    case complete
    case fail
    
    var title: String {
        switch self {
        case .submit:
            "제출 중이에요"
        case .complete:
            "제출이 완료됐어요"
        case .fail:
            "제출에 실패했어요"
        }
    }
    
    var subtitle: String {
        switch self {
        case .submit, .complete:
            ""
        case .fail:
            "다시 시도해보세요"
        }
    }
    
    var emoticon: String {
        switch self {
        case .submit, .complete:
            ""
        case .fail:
            "🥲"
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .submit:
            return .ellipsis
        case .complete:
            return .check
        case .fail:
            return .xmark
        }
    }
    
    var iconWidth: CGFloat {
        switch self {
        case .submit:
            return 35
        case .complete:
            return 31
        case .fail:
            return 24
        }
    }
    
    var color: IconColor {
        switch self {
        case .submit:
            return .blue
        case .complete:
            return .green
        case .fail:
            return .red
        }
    }
}

#Preview {
    VStack {
        SubmitStatusView(status: .submit, onConfirm: {})
        SubmitStatusView(status: .fail, onConfirm: {})
        SubmitCompleteView(quest: .mockData, action: {})
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.secondary)
}
