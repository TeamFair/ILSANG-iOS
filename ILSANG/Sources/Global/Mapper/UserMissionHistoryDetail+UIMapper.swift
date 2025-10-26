//
//  UserMissionHistoryDetail+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 10/25/25.
//

import UIKit

extension UserMissionHistoryDetail {
    func toItem(submitImage: UIImage?) -> UserMissionHistoryDetailItem {
        UserMissionHistoryDetailItem(
            missionHistoryId: missionHistoryId,
            title: title,
            createdAt: createdAt, // FIXME: 변경 date
            submitImageId: submitImageId,
            submitImage: submitImage,
            likeCount: likeCount,
            writerName: writerName,
            questType: questType,
            repeatType: repeatType,
            missionType: missionType,
            commercialGainPoint: commercialGainPoint,
            metroGainPoint: metroGainPoint,
            contributionGainPoint: contributionGainPoint,
            quizList: quizList
        )
    }
}
