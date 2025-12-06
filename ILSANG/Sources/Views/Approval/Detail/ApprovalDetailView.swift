//
//  ApprovalDetailView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/6/25.
//

import SwiftUI

struct ApprovalDetailView: View {
    @State private var activeMenuCommentId: Int?
    @State private var activeMissionhistoryMenu: Bool = false
    @State private var comment: String = ""
    @State private var replyingToComment: (id: Int, nickname: String)? = nil
    private let maxCommentLength = 300
    let item: ApprovalMissionHistoryItem
    var onAction: ((ApprovalDetailAction) -> Void)? = nil
    
    @Environment(\.layout) var layout
    @Environment(\.dismiss) var dismiss
    
    enum ApprovalDetailAction {
        case like
        case mission
        case profileTapped(userId: String)
        case commentEllipsisTapped
        case commentReport
        case commentDelete
        case missionHistoryEllipsisTapped
        case missionHistoryReport
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header  // 타이틀
            content
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .task {
            // await vm.loadDataIfNeeded() // FIXME: API 호출
        }
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            activeMissionhistoryMenu = false
            hideKeyboard()
        }
        .safeAreaInset(edge: .bottom) {
            inputView
        }
    }
    
    private var header: some View {
        NavigationTitleView(title: "인증 상세", isSeparatorHidden: true, background: .background) {
            dismiss()
        }
        .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ApprovalItemContentView(
                        id: item.id,
                        title: item.title,
                        image: item.image,
                        nickname: item.nickname,
                        userTitle: item.userTitle,
                        profileImage: item.profileImage,
                        displayDate: item.displayDate,
                        commercialAreaName: item.commercialAreaName,
                        width: .screenWidth - layout.horizontalPadding * 2,
                        height: ((.screenWidth-layout.horizontalPadding * 2) / 5) * 4,
                    ) {
                        onAction?(.profileTapped(userId: item.userId))
                    }
                    .overlay(alignment: .topTrailing) {
                        trailingButton(for: item)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, layout.horizontalPadding)
                    .padding(.bottom, 16)
                    
                    ApprovalQuestView(
                        questType: item.questType ?? .normal,
                        repeatType: item.repeatType,
                        questTitle: item.title,
                        writerName: item.writer ?? "",
                        approvalSource: .tab,
                        status: item.questStatus,
                        action: {
                            onAction?(.mission)
                        }
                    )
                    .padding(.bottom, 32)
                    .padding(.horizontal, layout.horizontalPadding)
                    
                    HStack(spacing: 4) {
                        Text("댓글")
                            .foregroundStyle(.black)
                            .styledFont(.heading1)
                        Text("\(item.comments.count)")
                            .foregroundStyle(.gray500)
                            .styledFont(.body)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal, layout.horizontalPadding)
                }
                .background(Color.white)
                
                divider
                
                if item.comments.isEmpty {
                    emptyCommentView
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(item.comments.enumerated()), id: \.offset) { idx, comment in
                            CommentView(
                                activeMenuCommentId: $activeMenuCommentId,
                                comment: comment) { action in
                                    
                                }
                                .overlay(alignment: .bottom) {
                                    if idx != CommentItem.mockList.count - 1 {
                                        divider
                                    }
                                }
                        }
                    }
                }
            }
            .cornerRadius(12, corners: [.topLeft, .topRight])
        }
        .padding(.bottom, -10)
        .padding(.horizontal, layout.horizontalPadding)
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                print("스크롤 중")
                activeMissionhistoryMenu = false
                activeMenuCommentId = nil
            }
        )
        .simultaneousGesture(
            TapGesture().onEnded {
                print("탭 발생")
                activeMissionhistoryMenu = false
                activeMenuCommentId = nil
            }
        )
    }
    
    private func trailingButton(for item: ApprovalMissionHistoryItem) -> some View {
        Button {
            withAnimation(.snappy) {
                onAction?(.missionHistoryEllipsisTapped)
            }
        } label: {
            Image(.moreVertical)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.gray500)
                .frame(height: 35)
        }
        .overlay(alignment: .topTrailing) {
            if activeMissionhistoryMenu {
                CommentMenuOverlay(
                    canDelete: false,
                    canReport: true,
                    onDelete: { },
                    onReport: {
                        onAction?(.missionHistoryReport)
                    }
                )
                .padding(.top, 40)
            }
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 0) {
            if let (_, nickname) = replyingToComment {
                HStack {
                    Text("\(nickname)님께 답글 남기는 중")
                        .styledFont(.caption2)
                        .foregroundStyle(.primaryPurple)
                    Spacer(minLength: 0)
                    Button {
                        replyingToComment = nil
                    } label: {
                        Text("취소")
                            .styledFont(.caption2)
                            .foregroundStyle(.gray400)
                            .frame(height: 30)
                    }
                }
                .padding(.horizontal, layout.horizontalPadding)
                .background(Color.primary100)
            }
            
            divider
            
            HStack(spacing: 8) {
                HStack(spacing: 10) {
                    TextField("", text: $comment, axis: .vertical)
                        .styledFont(.caption1)
                        .submitLabel(.return)
                        .keyboardType(.default)
                        .foregroundStyle(.black)
                        .overlay(alignment: .leading) {
                            if comment.isEmpty {
                                Text("댓글을 입력해 주세요.")
                                    .styledFont(.caption1)
                                    .foregroundStyle(.gray300)
                                    .padding(.leading, 2)
                                    .allowsHitTesting(false)
                            }
                        }
                    Text("\(comment.count)/\(maxCommentLength)")
                        .styledFont(.tabBold)
                        .foregroundStyle(.gray300)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .frame(minHeight: 50, alignment: .leading)
                .roundedBackground(cornerRadius: 12, bgColor: .gray100)
                
                Button {
                    
                } label: {
                    Text("등록")
                        .styledFont(.button)
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 50)
                        .roundedBackground(cornerRadius: 12, bgColor: comment.isEmpty ? .gray300 : .primaryPurple)
                }
                .disabled(comment.isEmpty)
            }
            .frame(maxHeight: 90, alignment: .top)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.vertical, 11)
        }
        .background(Color.white)
    }
    
    private var emptyCommentView: some View {
        Text("댓글이 아직 없어요.")
            .styledFont(.subTitle2)
            .foregroundStyle(.gray500)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
    }
    
    private var divider: some View {
        Rectangle()
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.gray100)
    }
}

#Preview {
    ApprovalDetailView(item: .mockDataList[0], onAction: nil)
}
