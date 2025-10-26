//
//  ChallengeListItemView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct UserMissionHistoryItemView: View {
    let missionHistory: UserMissionHistoryItem
    
    private let height = 172.0
    private let gradationHeight = 85.0
    
    var body: some View {
        switch missionHistory.missionType {
        case .quiz:
            content(hasImageBackground: false)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .roundedBackground(cornerRadius: 12)
        case .photo:
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                content(hasImageBackground: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .frame(height: height)
            .background(
                Group {
                    if let image = missionHistory.submitImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(uiImage: .logoWithAlpha)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                    }
                }
                    .scaledToFill()
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .frame(height: gradationHeight)
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [.clear, .black],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(missionHistory.submitImage == nil ? 0.2 : 0.6)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
        }
    }
    
    private func content(hasImageBackground: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(missionHistory.title)
                .styledFont(.heading1)
                .foregroundColor(hasImageBackground ? .white : .black)
            
            MissionTagGroupView(
                questType: missionHistory.questType,
                repeatType: missionHistory.repeatType,
                missionType: missionHistory.missionType
            )
            
            Text(missionHistory.createdAt.timeAgoCreatedAt())
                .styledFont(.caption1)
                .foregroundColor(hasImageBackground ? .gray200 : .gray400)
        }
    }
}

#Preview {
    let normal = UserMissionHistoryItem(
        missionHistoryId: 0,
        title: "일반 미션",
        createdAt: "2025-12-31T12:12:12",
        submitImageId: "",
        submitImage: .img0,
        questImageId: "",
        questImage: .img0,
        viewCount: 0,
        likeCount: 0,
        questType: .normal,
        repeatType: nil,
        missionType: .quiz(.ox)
    )
    let daily = UserMissionHistoryItem(
        missionHistoryId: 0,
        title: "daily 미션",
        createdAt: "2025-12-31T12:12:12",
        submitImageId: "",
        submitImage: .img0,
        questImageId: "",
        questImage: .img0,
        viewCount: 0,
        likeCount: 0,
        questType: .repeat,
        repeatType: .daily,
        missionType: .photo
    )
    
    let weekly = UserMissionHistoryItem(
        missionHistoryId: 0,
        title: "weekly 미션 타이틀",
        createdAt: "2025-12-31T12:12:12",
        submitImageId: "",
        submitImage: .img0,
        questImageId: "",
        questImage: .img0,
        viewCount: 0,
        likeCount: 0,
        questType: .repeat,
        repeatType: .weekly,
        missionType: .photo
    )
    
    let monthly = UserMissionHistoryItem(
        missionHistoryId: 0,
        title: "monthly 미션",
        createdAt: "2025-12-31T12:12:12",
        submitImageId: "",
        submitImage: .img0,
        questImageId: "",
        questImage: .img0,
        viewCount: 0,
        likeCount: 0,
        questType: .repeat,
        repeatType: .monthly,
        missionType: .photo
    )
    
    let event = UserMissionHistoryItem(
        missionHistoryId: 0,
        title: "event 미션",
        createdAt: "2025-12-31T12:12:12",
        submitImageId: "",
        submitImage: .img0,
        questImageId: "",
        questImage: .img0,
        viewCount: 0,
        likeCount: 0,
        questType: .event,
        repeatType: nil,
        missionType: .photo
    )
    
    ScrollView {
        UserMissionHistoryItemView(missionHistory: normal)
        UserMissionHistoryItemView(missionHistory: daily)
        UserMissionHistoryItemView(missionHistory: weekly)
        UserMissionHistoryItemView(missionHistory: monthly)
        UserMissionHistoryItemView(missionHistory: event)
        UserMissionHistoryItemView(missionHistory: event)
    }
    .padding()
    .background(Color.background)
}

