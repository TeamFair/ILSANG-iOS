//
//  CarouselAutoSlideView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/28/24.
//

import SwiftUI

struct CarouselAutoSlideView: View {
    @StateObject var vm: CarouselAutoSlideViewModel
    
    private let imageWidth = .screenWidth / 2
    private var imageHeight: CGFloat { self.imageWidth * self.imageRatio }
    private let imageRatio: CGFloat = 4 / 3
    
    init(images: [UIImage]) {
        self._vm = StateObject(wrappedValue: CarouselAutoSlideViewModel(images: images))
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(vm.extendedImages.indices, id: \.self) { idx in
                        Image(uiImage: vm.extendedImages[idx])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .scrollTransition(.interactive(timingCurve: .circularEaseIn), axis: .horizontal) { effect, phase in
                                effect
                                    .opacity(phase.isIdentity ? 1.0 : 0.5)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.8) // 약 6 : 5 비율
                            }
                            .id(idx)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.never)
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, imageWidth / 2)
            .frame(height: imageHeight)
            .allowsHitTesting(false)
            .onAppear {
                proxy.scrollTo(vm.currentIndex)
                vm.startAutoSlide()
            }
            .onDisappear {
                vm.stopAutoSlide()
            }
            .onChange(of: vm.currentIndex) { oldIdx, newIdx in
                // 이미지 인덱스가 바뀔 때마다 필요한 로직 처리
                if newIdx > 1 && newIdx < vm.totalExtendedImageCnt {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(newIdx)
                        vm.handleIndexTransition(from: oldIdx, to: newIdx)
                    }
                } else {
                    proxy.scrollTo(newIdx)
                }
            }
        }
    }
}

#Preview {
    CarouselAutoSlideView(images: [.img0])
        .frame(maxHeight: .infinity)
}

final class CarouselAutoSlideViewModel: ObservableObject {
    let images: [UIImage]
    let extendedImages: [UIImage]
    
    var totalExtendedImageCnt: Int {
        extendedImages.count
    }
    
    @Published var currentIndex: Int = 1
    
    private var slideTimer: Timer?
    private let slideTimeInterval: TimeInterval = 2.5
    private let transitionDelay: TimeInterval = 0.4
    
    init(images: [UIImage]) {
        if images.count >= 2 {
            extendedImages = [images[images.count-1]] + images + [images[0]] + [images[1]]
        } else {
            extendedImages = images
        }
        self.images = images
    }
    
    /// 슬라이드 타이머 시작
    func startAutoSlide() {
        self.stopAutoSlide() // 기존 타이머 중지
        if images.count <= 1 { return } // 1개이면 슬라이드 없이 반환
        
        let totalImages = self.images.count + 2
        self.slideTimer = Timer.scheduledTimer(withTimeInterval: slideTimeInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                withAnimation {
                    self.currentIndex = (self.currentIndex + 1) % totalImages
                }
            }
        }
    }
    
    ///  타이머 중지
    func stopAutoSlide() {
        slideTimer?.invalidate()
        slideTimer = nil
    }
    
    /// 이미지 전환 시 처리 로직
    func handleIndexTransition(from oldIdx: Int, to newIdx: Int) {
        if newIdx == totalExtendedImageCnt - 2 {
            moveToFirstImage()
        }
    }
    
    private func moveToFirstImage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDelay) {
            self.currentIndex = 1
        }
    }
}
