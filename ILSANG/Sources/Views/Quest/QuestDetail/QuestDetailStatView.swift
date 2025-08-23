//
//  QuestDetailStatView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/4/25.
//

import SwiftUI

struct QuestDetailStatView: View {
    let quest: QuestViewModelItem
    
    var body: some View {
        VStack(spacing: 16) {
            QuestDetailTitleView(title: "획득 가능 포인트")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                ForEach(PointType.sorted, id: \.rawValue) { type in
                    if let point = quest.rewards?.first(where: { $0.pointType == type }) {
                        pointTagView(type: type, point: point.point)
                    }
                }
            }
        }
    }
    
    private func pointTagView(type: PointType, point: Int) -> some View {
        VStack(spacing: 8) {
            Text(type.headerText)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.gray500)
                .padding(.vertical, 4)
                .frame(width: 52)
                .roundedBackground(cornerRadius: 9, bgColor: .background)
               
            VStack(spacing: 4) {
                Image(type.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                
                HStack(spacing: 0) {
                    Text("\(point)P")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primaryPurple)
                    Image(.arrowUp)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12)
                        .frame(width: 20, height: 20)
                }
                .frame(height: 20)
            }
        }
    }
}

#Preview {
    QuestDetailStatView(quest: .mockData)
}
