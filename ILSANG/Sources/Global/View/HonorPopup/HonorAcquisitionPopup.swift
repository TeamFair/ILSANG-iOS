//
//  HonorAcquisitionPopup.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/18/25.
//

import SwiftUI

struct HonorAcquisitionPopup: View {
    let honorTitle: String
    let honorGrade: HonorGrade
    let onConfirm: () -> ()
    
    var body: some View {
        VStack(spacing: 16) {
            Image(.confettiPurple)
                .resizable()
                .frame(55)
            
            Text("칭호를 획득했어요!")
                .styledFont(.bold, size: 17, lineHeight: 18)
                .foregroundColor(.gray500)
            
            HonorIconView(honorTitle: honorTitle, grade: honorGrade, imageSize: 24, spacing: 8, font: .caption1, fgColor: .gray400)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.background)
                )
            
            PrimaryButton(title: "확인") {
                onConfirm()
            }
        }
        .padding(16)
        .frame(width: 260, height: 240)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
    }
}

#Preview {
    HonorAcquisitionPopup(honorTitle: "체력왕", honorGrade: .legend) { }
}
