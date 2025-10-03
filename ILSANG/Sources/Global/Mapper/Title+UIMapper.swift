//
//  Title+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/7/25.
//

import Foundation

extension Title {
    func toItem(userTitles: [UserTitle], currentSelectedId: Int?) -> TitleItem {
        // 해당 타이틀을 유저가 보유했는지 확인
        let userTitle = userTitles.first { $0.name == self.name }
        
        return TitleItem(
            titleId: id,
            name: name,
            condition: condition,
            grade: grade,
            historyId: userTitle?.titleHistoryId,
            isSelected: (userTitle?.titleHistoryId != nil && userTitle?.titleHistoryId == currentSelectedId)
        )
    }
    
    func toItem() -> TitleItem {
        TitleItem(
            titleId: id,
            name: name,
            condition: condition,
            grade: grade,
            historyId: nil,
            isSelected: false
        )
    }
}
