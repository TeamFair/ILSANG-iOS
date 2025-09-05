//
//  CouponListItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//


import SwiftUI

struct CouponListItem: View {
    let item: UserCouponItem
    
    var body: some View {
        Group {
            if item.useYn {
                usedCouponView
            } else {
                availableCouponView
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .roundedBackground(cornerRadius: 12)
    }
    
    private var usedCouponView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.coupon.name)
                    .styledFont(.heading1)
                    .foregroundStyle(.gray400)
                
                Text(item.coupon.storeName)
                    .styledFont(.body)
                    .foregroundStyle(.gray300)
                
                Text(item.expireAtText)
                    .styledFont(.tabRegular)
                    .foregroundStyle(.gray300)
                
                Text(item.redeemedText)
                    .styledFont(.badge1)
                    .foregroundStyle(.gray400)
            }
            Spacer(minLength: 0)
        }
    }
    
    private var availableCouponView: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.coupon.name)
                    .styledFont(.heading1)
                    .foregroundStyle(.primaryPurple)
                
                Text(item.coupon.storeName)
                    .styledFont(.body)
                    .foregroundStyle(.gray500)
                
                Text(item.expireAtText )
                    .styledFont(.tabRegular)
                    .foregroundStyle(.gray400)
            }
            Spacer(minLength: 0)
            ChevronCircleView()
        }
    }
}
