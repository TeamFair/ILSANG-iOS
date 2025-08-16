//
//  AnalyticsService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/25/25.
//

import FirebaseAnalytics

final class AnalyticsService {
    static func logEvent(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}

enum AnalyticsEvent {
    case bottomTabClick(tabName: String)
    case homeBannerClick(bannerId: Int)
    case homePopularQuestClick(questId: String)
    case homeRecommendQuestClick(questId: String)
    case homeBigRewardQuestClick(questId: String)
    case homeRankingClick(userId: String)
    case questFilterClick(filterOption: String)
    case questItemClick(questId: String, questType: String)
    case questSubmitClick(questId: String, questType: String)
    
    var name: String {
        switch self {
        case .bottomTabClick: "bottom_tab_click"
        case .homeBannerClick: "home_banner_click"
        case .homePopularQuestClick: "home_popular_quest_click"
        case .homeRecommendQuestClick: "home_recommend_quest_click"
        case .homeBigRewardQuestClick: "home_big_reward_quest_click"
        case .homeRankingClick: "home_ranking_click"
        case .questFilterClick: "quest_filter_click"
        case .questItemClick: "quest_item_click"
        case .questSubmitClick: "quest_submit_click"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .bottomTabClick(let tabName):
            ["tab_name": tabName]
        case .homeBannerClick(let bannerId):
            ["banner_id": bannerId]
        case .homePopularQuestClick(let questId):
            ["quest_id": questId]
        case .homeRecommendQuestClick(let questId):
            ["quest_id": questId]
        case .homeBigRewardQuestClick(let questId):
            ["quest_id": questId]
        case .homeRankingClick(let userId):
            ["user_id": userId]
        case .questFilterClick(let filterOption):
            ["filter_option": filterOption]
        case .questItemClick(let questId, let questType):
            ["quest_id": questId, "quest_type": questType]
        case .questSubmitClick(let questId, let questType):
            ["quest_id": questId, "quest_type": questType]
        }
    }
}
