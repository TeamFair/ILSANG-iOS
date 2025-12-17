//
//  CommentView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 11/29/25.
//

import SwiftUI

enum CommentAction {
    case delete(id: Int)
    case report(id: Int)
    case reply(id: Int, name: String)
    case showUserProfile(userId: String)
}

struct CommentView: View {
    @Binding var activeMenuCommentId: Int?
    let comment: CommentItem
    let onAction: (CommentAction) -> Void
    private var isMenuActive: Bool {
        activeMenuCommentId == comment.id
    }
    @Environment(\.layout) var layout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch comment.state {
            case .normal:
                normalCommentView
            case .deleted:
                deletedCommentView
            case .reported:
                reportedCommentView
            }
        }
        .overlay(alignment: .topTrailing) {
            if isMenuActive {
                CommentMenuOverlay(
                    canDelete: comment.isFromCurrentUser,
                    canReport: !comment.isFromCurrentUser,
                    onDelete: {
                        onAction(.delete(id: comment.id))
                    },
                    onReport: {
                        onAction(.report(id: comment.id))
                    }
                )
                .padding(.top, 40)
            }
        }
        .padding(layout.horizontalPadding)
        .padding(.leading, comment.isReplyComment ? layout.horizontalPadding : 0)
        .background(comment.isReplyComment ? Color.contentBackground : .white)
    }
    
    @ViewBuilder
    private var normalCommentView: some View {
        HStack {
            Button {
                onAction(.showUserProfile(userId: comment.userId))
            } label: {
                ProfileView(
                    profileImage: comment.profileImage,
                    nickname: comment.nickname,
                    honor: comment.userTitle,
                    isWriter: comment.isWriter
                )
            }
            
            Spacer(minLength: 0)
            
            Button {
                withAnimation(.snappy) {
                    if isMenuActive {
                        activeMenuCommentId = nil
                    } else {
                        activeMenuCommentId = comment.id
                    }
                }
            } label: {
                Image(.moreVertical)
            }
            .foregroundStyle(.gray500)
        }
        
        Text(comment.content.forceCharWrapping)
            .styledFont(.caption1)
            .multilineTextAlignment(.leading)
            .foregroundStyle(.black)
        
        HStack(spacing: 0) {
            if !comment.isReplyComment {
                Button {
                    onAction(.reply(id: comment.id, name: comment.nickname))
                } label: {
                    Text("답글 달기")
                        .styledFont(.tabBold)
                        .foregroundStyle(.primary300)
                }
                Spacer(minLength: 0)
            }
            if let createdAt = comment.date?.toDisplayFormat(.full) {
                Text(createdAt)
                    .styledFont(.caption2)
                    .foregroundStyle(.gray500)
            }
        }
    }
    
    private var reportedCommentView: some View {
        Text("신고 누적으로 숨겨진 댓글입니다.")
            .styledFont(.subTitle2)
            .foregroundStyle(.gray500)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
    }
    
    private var deletedCommentView: some View {
        Text("삭제된 댓글입니다.")
            .styledFont(.subTitle2)
            .foregroundStyle(.gray500)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
    }
}

struct CommentMenuOverlay: View {
    let canDelete: Bool
    let canReport: Bool
    let onDelete: () -> Void
    let onReport: () -> Void
    
    var body: some View {
        Group {
            if canDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    HStack {
                        Text("삭제")
                            .styledFont(.regular, size: 15, lineHeight: 15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(.trash)
                            .resizable()
                            .scaledToFit()
                            .frame(15)
                    }
                    .frame(height: 40)
                }
            }
            
            if canReport {
                Button {
                    onReport()
                } label: {
                    HStack {
                        Text("신고")
                            .styledFont(.regular, size: 15, lineHeight: 15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(.syren)
                            .resizable()
                            .scaledToFit()
                            .frame(15)
                    }
                    .frame(height: 40)
                }
            }
        }
        .foregroundStyle(.gray500)
        .padding(.horizontal, 12)
        .frame(width: 150)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .stroke(.gray100, style: StrokeStyle(lineWidth: 1))
        )
        .shadow(color: .shadow7D.opacity(0.05), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    @Previewable @State var activeMenuCommentId: Int? = nil
    ZStack {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(CommentItem.mockList) { item in
                    CommentView(activeMenuCommentId: $activeMenuCommentId, comment: item, onAction: { _ in })
                    Divider()
                }
            }
        }
        .simultaneousGesture(
            DragGesture().onChanged { _ in
                print("스크롤 중")
                activeMenuCommentId = nil
            }
        )
        .simultaneousGesture(
            TapGesture().onEnded {
                print("탭 발생")
                activeMenuCommentId = nil
            }
        )
    }
}

