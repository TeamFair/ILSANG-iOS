//
//  CouponSheetView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//


import SwiftUI

struct CouponSheetView: View {
    @ObservedObject var viewModel: CouponListViewModel
    @Environment(\.layout) var layout
    let item: UserCouponItem
    
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.sheetStatus {
            case .info:
                Image(.coupon)
                    .resizable()
                    .scaledToFit()
                    .frame(96)
                VStack(spacing: 4) {
                    Text(item.coupon.name)
                        .styledFont(.title2)
                        .foregroundStyle(.black)
                    
                    if let storeName = item.coupon.storeName {
                        Text(storeName)
                            .styledFont(.body)
                            .foregroundStyle(.gray500)
                    }
                    
                    Text(item.expireAtText)
                        .styledFont(.tabRegular)
                        .foregroundStyle(.gray400)
                }
                Spacer(minLength: 0)
            case .passwordInput:
                HStack(spacing: 20) {
                    Image(.coupon)
                        .resizable()
                        .scaledToFit()
                        .frame(52)
                        .frame(60)
                        .background(
                            Circle().fill(.badgeBlue)
                        )
                    VStack(alignment: .leading, spacing: 0) {
                        Text(item.coupon.name)
                            .styledFont(.heading2)
                            .foregroundStyle(.black)
                        if let storeName = item.coupon.storeName {
                            Text(storeName)
                                .styledFont(.badge1)
                                .foregroundStyle(.gray400)
                        }
                        Text(item.expireAtText)
                            .styledFont(.tabRegular)
                            .foregroundStyle(.gray400)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 20)
                .padding(.leading, 24)
                
                Divider()
                    .background(Color.gray100)
                    .padding(.bottom, 18)
                
                Text("비밀번호 4자리를 입력해 주세요")
                    .styledFont(.heading1)
                    .foregroundStyle(.black)
                    .padding(.bottom, 16)
                
                PinCodeView(pin: $viewModel.password, showPasswordError: $viewModel.showPasswordError)
                    .padding(.bottom, 8)
                
                Text("쿠폰은 사용 후 되돌릴 수 없습니다\n쿠폰을 사용하시겠습니까?")
                    .styledFont(.tabRegular)
                    .foregroundStyle(.gray500)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(alignment: .top)
        .foregroundStyle(.gray500)
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 30, height: 4)
                    .foregroundStyle(.gray100)
                    .padding(.top, 8)
                    .padding(.bottom, 14)
                
                Text(viewModel.sheetStatus.title)
                    .styledFont(.title2)
                    .foregroundStyle(.gray500)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 15)
            }
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(
                title: viewModel.sheetStatus.buttonTitle,
                buttonAble: viewModel.isButtonEnabled
            ) {
                viewModel.buttonAction()
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, layout.horizontalPadding)
    }
}
