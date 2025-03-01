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
    let item: ApprovalViewModelItem
    
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                profileView(nickname: item.nickname, time: item.time)
                
                Text(item.title)
                    .font(.system(size: 23, weight: .bold))
                    .frame(height: 24)
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
                
                HStack(spacing: 16) {
                    emojiView(imageName: .thumbsUp, count: item.likeCnt, alignment: .top)
                    emojiView(imageName: .thumbsDown, count: item.hateCnt, alignment: .bottom)
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
    
    private func profileView(nickname: String, time: String) -> some View {
        HStack(spacing: 10) {
            Image(.profileCircle)
                .resizable()
                .frame(width: 35, height: 35)
            VStack(alignment: .leading, spacing: 3) {
                Text(nickname)
                    .font(.system(size: 14, weight: .semibold))
                Text(time)
                    .font(.system(size: 12, weight: .regular))
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

import SwiftUI

struct ApprovalItemContentShareView: View {
    let item: ApprovalViewModelItem
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            profileView(nickname: item.nickname, time: item.time)
            
            Text(item.title)
                .font(.system(size: 23, weight: .bold))
                .frame(height: 24)
                .foregroundStyle(.black)
            
            Image(uiImage: item.image ?? .logo)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack(spacing: 16) {
                emojiView(imageName: .thumbsUp, count: item.likeCnt, alignment: .top)
                emojiView(imageName: .thumbsDown, count: item.hateCnt, alignment: .bottom)
            }
        }
    }
    
    private func profileView(nickname: String, time: String) -> some View {
        HStack(spacing: 10) {
            Image(.profileCircle)
                .resizable()
                .frame(width: 35, height: 35)
            VStack(alignment: .leading, spacing: 3) {
                Text(nickname)
                    .font(.system(size: 14, weight: .semibold))
                Text(time)
                    .font(.system(size: 12, weight: .regular))
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
