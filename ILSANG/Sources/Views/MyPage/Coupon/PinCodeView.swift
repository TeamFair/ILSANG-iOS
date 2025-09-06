//
//  PinCodeView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 9/5/25.
//


import SwiftUI

struct PinCodeView: View {
    @Binding var pin: String
    @Binding var showPasswordError: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 10) {
                ForEach(0..<4) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray100)
                            .frame(width: 67, height: 74)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        showPasswordError ? Color.subRed : .clear,
                                        style: StrokeStyle(lineWidth: 2)
                                    )
                            )
                        
                        // index번째 숫자가 있으면 표시
                        if index < pin.count {
                            Text(String(pin[pin.index(pin.startIndex, offsetBy: index)]))
                                .foregroundStyle(showPasswordError ? .red : .black)
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
                        
                        // 입력이 바뀌면 에러 상태 해제
                        if pin.count <= 3 && showPasswordError {
                            withAnimation {
                                showPasswordError = false
                            }
                        }
                    }
            }
            .onTapGesture {
                isFocused = true
            }
            
            Text(showPasswordError ? "비밀번호 오류입니다." : "")
                .styledFont(.badge2)
                .foregroundStyle(.subRed)
        }
    }
}

#Preview {
    PinCodeView(pin: .constant("22"), showPasswordError: .constant(true))
    PinCodeView(pin: .constant(""), showPasswordError: .constant(false))
}
