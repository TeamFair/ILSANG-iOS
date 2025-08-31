//
//  ApprovalItemContentView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/1/25.
//


import SwiftUI

/// 18 버전 미만 > 시트로 이미지 확대 표시
/// 18 버전 이상 > 네비게이션 이동(zoom 효과)
struct ApprovalItemContentView: View {
    @Namespace var namespace
    
    @State var showMagView: Bool = false
    @State var showSheetView: Bool = false
    let item: ApprovalMissionHistoryItem
    
    let width: CGFloat
    let height: CGFloat
    
    let onOtherUserTapped: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Button {
                    onOtherUserTapped()
                } label: {
                    profileView(nickname: item.nickname, honor: item.userTitle)
                }
                
                Text(item.title)
                    .styledFont(.title1)
                    .foregroundStyle(.black)
                
                if #available(iOS 18.0, *) {
                    Image(uiImage: item.image ?? .logo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .matchedTransitionSource(id: item.id, in: namespace)
                        .onTapGesture {
                            showMagView.toggle()
                        }
                } else {
                    Image(uiImage: item.image ?? .logo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            showSheetView.toggle()
                        }
                }
                
                HStack(spacing: 4) {
                    Text(item.displayDate)
                        .font(.system(size: 12, weight: .regular))
                    Spacer(minLength: 0)
                    if let commercialAreaName = item.commercialAreaName, !commercialAreaName.isEmpty {
                        Image(.illsangRegion)
                            .resizable()
                            .scaledToFit()
                            .frame(18)
                        Text(commercialAreaName)
                            .styledFont(.badge1)
                    }
                }
                .foregroundStyle(.gray500)
                
                HStack(spacing: 16) {
                    emojiView(imageName: .thumbsUp, count: item.likeCount, alignment: .top)
                    emojiView(imageName: .thumbsDown, count: item.hateCount, alignment: .bottom)
                }
            }
            .sheet(isPresented: $showSheetView, content: {
                ImageFullScreenView(image: item.image ?? .logo) {
                    showSheetView.toggle()
                }
            })
            .navigationDestination(isPresented: $showMagView) {
                if #available(iOS 18.0, *) {
                    ImageFullScreenView(image: item.image ?? .logo) {
                        showMagView.toggle()
                    }
                    .navigationTransition(.zoom(sourceID: item.id, in: namespace))
                } else {
                    ImageFullScreenView(image: item.image ?? .logo) {
                        showMagView.toggle()
                    }
                }
            }
        }
    }
    
    private func profileView(nickname: String, honor: UserTitle?) -> some View {
        HStack(spacing: 10) {
            Image(uiImage: item.profileImage ?? .profileCircle)
                .resizable()
                .frame(width: 35, height: 35)
                .clipShape(.circle)
            VStack(alignment: .leading, spacing: 4) {
                Text(nickname)
                    .font(.system(size: 14, weight: .semibold))
                if let honor {
                    HonorIconView(honorTitle: honor.name, grade: honor.grade, imageSize: 20, spacing: 4, font: .badge1, fgColor: .gray500)
                }
            }
        }
    }
    
    private func emojiView(imageName: UIImage, count: Int, alignment: Alignment) -> some View {
        HStack(spacing: 4) {
            Image(uiImage: imageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 21, height: 21)
                .foregroundStyle(.gray200)
                .frame(width: 24, height: 24, alignment: alignment)
            Text(String(count))
                .monospacedDigit()
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.gray300)
        }
        .frame(height: 24)
    }
}

struct ApprovalItemContentShareView: View {
    let item: ApprovalMissionHistoryItem
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            profileView(nickname: item.nickname, honor: item.userTitle)

            Text(item.title)
                .styledFont(.title1)
                .foregroundStyle(.black)
            
            Image(uiImage: item.image ?? .logo)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack(spacing: 4) {
                Text(item.displayDate)
                    .font(.system(size: 12, weight: .regular))
                Spacer(minLength: 0)
                if let commercialAreaName = item.commercialAreaName, !commercialAreaName.isEmpty {
                    Image(.illsangRegion)
                        .resizable()
                        .scaledToFit()
                        .frame(18)
                    Text(commercialAreaName)
                        .styledFont(.badge1)
                }
            }
            .foregroundStyle(.gray500)
            
            HStack(spacing: 16) {
                emojiView(imageName: .thumbsUp, count: item.likeCount, alignment: .top)
                emojiView(imageName: .thumbsDown, count: item.hateCount, alignment: .bottom)
            }
        }
        .background(.white)
    }
    
    private func profileView(nickname: String, honor: UserTitle?) -> some View {
        HStack(spacing: 10) {
            Image(uiImage: item.profileImage ?? .profileCircle)
                .resizable()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(nickname)
                    .font(.system(size: 14, weight: .semibold))
                if let honor {
                    HonorIconView(honorTitle: honor.name, grade: honor.grade, imageSize: 20, spacing: 4, font: .badge1, fgColor: .gray500)
                }
            }
            .foregroundStyle(.gray500)
        }
    }
    
    private func emojiView(imageName: UIImage, count: Int, alignment: Alignment) -> some View {
        HStack(spacing: 4) {
            Image(uiImage: imageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 21, height: 21)
                .foregroundStyle(.gray200)
                .frame(width: 24, height: 24, alignment: alignment)
            Text(String(count))
                .monospacedDigit()
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.gray300)
        }
        .frame(height: 24)
    }
}

#Preview {
    VStack {
        ApprovalItemContentView(item: .mockDataList[0], width: .screenWidth-40, height:  ((.screenWidth-40) / 5) * 4, onOtherUserTapped: {})
        ApprovalItemContentShareView(item: .mockDataList[1], width: .screenWidth-40, height:  ((.screenWidth-40) / 5) * 4)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}
