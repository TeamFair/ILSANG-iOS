//
//  Buttons.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var buttonAble: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .background(buttonAble ? Color.accentColor: Color.gray300)
                .cornerRadius(12)
        }
        .disabled(!buttonAble)
    }
}


#Preview {
    VStack {
        PrimaryButton(title: "일상 버튼", action: {print("tapped")})
        PrimaryButton(title: "일상 버튼", buttonAble: false, action: {print("tapped")})

    }
}
