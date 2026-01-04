//
//  QuestCouponView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 9/15/25.
//

import SwiftUI

struct QuestCouponView: View {
    let coupon: CouponItem
    var buttonTitle: String = "확인"
    var onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0){
            HStack {
                Text(coupon.type?.title ?? "")
                    .styledFont(.heading2)
                    .foregroundStyle(.black)
                Spacer()
                Button {
                    onDismiss?()
                } label: {
                    XmarkButton()
                }
            }
            .padding(.bottom, 16)
            
            Image(.coupon)
                .resizable()
                .scaledToFit()
                .frame(82)
                .frame(132)
                .background(
                    Circle().fill(Color.navy)
                )
                .padding(.bottom, 16)
            
            Text(coupon.name)
                .styledFont(.title2)
                .foregroundStyle(.black)
                .padding(.bottom, 8)
            
            Text(coupon.storeName ?? "")
                .styledFont(.subTitle1)
                .foregroundStyle(.gray500)
                .padding(.bottom, 3)
            
            Text(coupon.expireAtText)
                .styledFont(.tabRegular)
                .foregroundStyle(.gray400)
                .padding(.bottom, 48)
            
            PrimaryButton(title: buttonTitle) {
                onDismiss?()
            }
        }
        .padding(16)
        .roundedBackground(cornerRadius: 12)
    }
}

#Preview {
    QuestCouponView(
        coupon: CouponItem(
            id: 0,
            name: "쿠폰1",
            imageId: nil,
            image: nil,
            storeName: "서현가게",
            description: nil,
            type: nil,
            validFrom: .now,
            validTo: .now
        )
    )
    .frame(height: 700)
    .background(Color.background)
}
