//
//  MyPageBadgeList.swift
//  ILSANG
//
//  Created by Kim Andrew on 7/18/24.
//

import SwiftUI

struct MyPageBadgeList: View {
    
    @ObservedObject var vm: MypageViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("최근 활동 순")
                .font(.system(size: 14))
                .fontWeight(.medium)
                .foregroundColor(.gray400)
            
            // Data List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(vm.xpLogList, id: \.recordId) { Data in
                        ListStruct(title: Data.title, detail: Data.createDate.timeAgoCreatedAt(), point: Data.xpPoint)
                    }
                }
            }
            .refreshable {
                // 데이터 리프레시
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
