//
//  ApprovalQuestView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 11/30/25.
//

import SwiftUI

struct ApprovalQuestView: View {
    @Environment(\.layout) var layout
    let questType: QuestType
    let repeatType: RepeatType?
    let questTitle: String
    let writerName: String
    let approvalSource: ApprovalSource
    let status: ApprovalQuestStatus
    let action: () -> Void
    
    enum ApprovalQuestStatus: Equatable {
        case able, expired, completed
        
        func getButtonTitle(source: ApprovalSource) -> String {
            switch self {
            case .able:
                switch source {
                case .tab: "나도 하기"
                case .detail: "바로가기"
                }
            case .expired: "기간 만료"
            case .completed: "수행 완료"
            }
        }
    }
    
    var actionDisable: Bool {
        if case .able = status { false } else { true }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                MissionTagGroupView(questType: questType, repeatType: repeatType, missionType: .photo)
                VStack(alignment: .leading, spacing: 0) {
                    Text(questTitle)
                        .styledFont(.bold, size: 15, lineHeight: 20)
                        .foregroundStyle(.black)
                    Text(writerName)
                        .styledFont(.regular, size: 11, lineHeight: 16)
                        .foregroundStyle(.gray400)
                }
            }
            
            Spacer(minLength: 0)
            
            Button {
                action()
            } label: {
                HStack(spacing: 0) {
                    Text(status.getButtonTitle(source: approvalSource))
                        .styledFont(.tabBold)
                    
                    Image(.arrowUnder)
                        .resizable()
                        .scaledToFit()
                        .frame(20)
                        .rotationEffect(.degrees(-90))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
            }
            .foregroundStyle(actionDisable ? .gray300 : .gray500)
            .roundedBackground(cornerRadius: 12, bgColor: .background)
            .disabled(actionDisable)
        }
        .padding(.horizontal, approvalSource == .tab ? 16 : layout.horizontalPadding)
        .padding(.vertical, 16)
        .background(
            ZStack {
                if case .detail = approvalSource {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(.gray100)
                            .frame(height: 1)
                        Spacer()
                        Rectangle()
                            .fill(.gray100)
                            .frame(height: 1)
                    }
                    .background(.white)
                } else {
                    RoundedRectangle(cornerRadius: approvalSource == .tab ? 12 : 0)
                        .fill(.white)
                        .strokeBorder(.gray100, style: .init(lineWidth: 1))
                }
            }
        )
    }
}
#Preview {
    let action = { print("tapped") }
    ScrollView {
        ApprovalQuestView(questType: .normal, repeatType: nil, questTitle: "일반 퀘스트", writerName: "작성자이름", approvalSource: .tab, status: .able, action: action )
        ApprovalQuestView(questType: .repeat, repeatType: .daily, questTitle: "일간 퀘스트", writerName: "작성자이름", approvalSource: .tab, status: .able, action: action)
        ApprovalQuestView(questType: .repeat, repeatType: .weekly, questTitle: "주간 퀘스트", writerName: "작성자이름", approvalSource: .tab, status: .able, action: action)
        ApprovalQuestView(questType: .repeat, repeatType: .monthly, questTitle: "월간 퀘스트", writerName: "작성자이름", approvalSource: .tab, status: .able, action: action)
        ApprovalQuestView(questType: .event, repeatType: nil, questTitle: "이벤트 퀘스트 참여완료", writerName: "작성자이름", approvalSource: .tab, status: .completed, action: action)
        ApprovalQuestView(questType: .event, repeatType: nil, questTitle: "이벤트 퀘스트 기간만료", writerName: "작성자이름", approvalSource: .tab, status: .expired, action: action)
        ApprovalQuestView(questType: .repeat, repeatType: .daily, questTitle: "인증예시 퀘스트", writerName: "작성자이름", approvalSource: .detail(missionId: 2), status: .able, action: action)
    }
    .padding(20)
}
