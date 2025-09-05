//
//  PinCodeView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//


import SwiftUI

struct PinCodeView: View {
    @Binding var pin: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<4) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray100)
                        .frame(width: 67, height: 74)
                    
                    // index번째 숫자가 있으면 표시
                    if index < pin.count {
                        Text(String(pin[pin.index(pin.startIndex, offsetBy: index)]))
                            .foregroundStyle(.black)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
            }
        }
        .background {
            // 숨겨진 TextField
            TextField("", text: $pin)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .frame(height: 74)
                .onChange(of: pin) { _, newValue in
                    if newValue.count > 4 {
                        pin = String(newValue.prefix(4))
                    }
                }
        }
        .onTapGesture {
            isFocused = true
        }
    }
}
