//
//  IllsangZoneAlertView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/3/25.
//


import SwiftUI

struct IllsangZoneAlertView: View {
    let alertType: IllsangZoneAlertType
    @Binding var isNeverShowSelected: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        SettingAlertView(
            alertType: alertType,
            onCancel: alertType == .illsangZoneNotSelected ? onCancel : nil,
            onConfirm: onConfirm
        ) {
            if alertType == .illsangZoneNotSelected {
                Button {
                    isNeverShowSelected.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(.checkThin)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 9, height: 5.5)
                            .frame(16)
                            .foregroundStyle(isNeverShowSelected ? .white : .clear)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(
                                        isNeverShowSelected ? .clear : .gray200,
                                        style: StrokeStyle(lineWidth: 1)
                                    )
                                    .fill(isNeverShowSelected ? .primaryPurple : .clear)
                            )
                            .frame(24)
                        Text("다시 보지 않기")
                            .styledFont(.tabRegular)
                            .foregroundStyle(.gray500)
                    }
                }
            }
        }
    }
}