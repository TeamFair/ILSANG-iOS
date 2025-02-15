//
//  MyPageActiveList.swift
//  ILSANG
//
//  Created by Kim Andrew on 7/18/24.
//

import SwiftUI

struct MyPageActiveList: View {
    
    @ObservedObject var vm: MyPageViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("최근 활동 순")
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundColor(.gray400)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Data List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(vm.xpLogList, id: \.recordId) { xpLog in
                        MyPageListItemView(title: xpLog.title, detail: xpLog.createDate.timeAgoSinceCreation(), point: xpLog.xpPoint)
                    }
                }
                .padding(.bottom, 60)
            }
            .refreshable {
                await vm.fetchXpLog(page: 0, size: 10)
            }
        }
        .overlay {
            if vm.xpLogList.isEmpty {
                EmptyView(title: "활동 내역이 없어요!")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MyPageListItemView: View {
    let title: String
    let detail: String
    let point: Int?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Text(detail)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray500)
            }
            
            Spacer()
            
            if let point = point {
                Text("\(point > 0 ? "+\(point)" : "\(point)")XP")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.accentColor)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.white)
        )
    }
}
