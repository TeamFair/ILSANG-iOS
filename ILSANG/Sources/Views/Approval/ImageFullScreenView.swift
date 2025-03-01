//
//  ImageFullScreenView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/1/25.
//

import SwiftUI

/// 핀치 줌 기능
/// 최소 배율 1.0 유지
/// 더블 탭 >> 해당 위치 기준 3배
struct ImageFullScreenView: View {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero // 드래그 위치 저장
    @State private var anchor: UnitPoint = .center // 확대 기준점
    
    let image: UIImage
    let onTap: () -> ()
    
    var body: some View {
        ZStack {
            PinchToZoomView(image: image)
            
            Button {
                onTap()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .frame(width: 34, height: 34)
                    .background(.ultraThinMaterial.opacity(0.4))
                    .clipShape(Circle())
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(10)
            .padding(.trailing, 6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .background(.black)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ImageFullScreenView(image: .img0, onTap: {})
}

struct PinchToZoomView: View {
    let image: UIImage
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var anchorPoint: UnitPoint = .center
    @State private var isFirstZoom = true // 첫 확대 여부 추적
    
    @GestureState private var magnifyBy = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(scale, anchor: anchorPoint)
                .gesture(
                    MagnifyGesture()
                        .updating($magnifyBy) { value, gestureState, _ in
                            gestureState = value.magnification
                        }
                        .onChanged { value in
                            let newScale = lastScale * value.magnification
                            scale = max(1.0, newScale) // 최소 배율 1.0 유지
                        }
                        .onEnded { value in
                            withAnimation {
                                lastScale = max(1.0, scale) // 현재 배율 저장
                                if isFirstZoom {
                                    anchorPoint = UnitPoint(x: value.startAnchor.x, y: value.startAnchor.y) // 첫 확대 시 anchor 설정
                                    isFirstZoom = false // 이후 확대 시 anchor 변경 방지
                                }
                                if lastScale == 1.0 {
                                    isFirstZoom = true
                                }
                            }
                        }
                )
                .onTapGesture(count: 2, coordinateSpace: .local) { event in
                    if scale > 1.0 {
                        withAnimation {
                            scale = 1.0
                            lastScale = 1.0
                            isFirstZoom = true // 축소 시 다시 첫 확대 가능하도록 초기화
                        }
                    } else {
                        anchorPoint = UnitPoint(x: event.x / geometry.size.width, y: event.y / geometry.size.height)
                        withAnimation {
                            scale = 3.0
                            lastScale = 3.0
                            isFirstZoom = false // 이후 확대 시 anchor 변경 방지
                        }
                    }
                }
        }
    }
}
