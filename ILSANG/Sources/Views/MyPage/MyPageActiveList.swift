//
//  MyPageActiveList.swift
//  ILSANG
//
//  Created by Kim Andrew on 7/18/24.
//

import SwiftUI

struct MyPageActiveList: View {
    
    @ObservedObject var vm: MypageViewModel
    
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
                    ForEach(vm.xpLogList, id: \.recordId) { Data in
                        ListStruct(title: Data.title, detail: Data.createDate.timeAgoSinceCreation(), point: Data.xpPoint)
                    }
                }
            }
            .refreshable {
                await vm.getxpLog(page: 0, size: 10)
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
