//
//  CustomImagePicker.swift
//  SwiftUIStudy
//
//  Created by Lee Jinhee on 3/10/25.
//

import SwiftUI
import PhotosUI

struct CustomImagePicker<Content: View>: View {
    var content: Content
    @Binding var show: Bool
    @Binding var croppedImage: UIImage?
    
    init(show: Binding<Bool>, croppedImage: Binding<UIImage?>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._show = show
        self._croppedImage = croppedImage
    }
    
    @State private var photosItem: PhotosPickerItem?
    @State private var selectedImage: UIImage? = .logoWithAlpha
    @State private var showCropView: Bool = false
    
    var body: some View {
        content
            .photosPicker(isPresented: $show, selection: $photosItem)
            .onChange(of: photosItem) { _, newValue in
                if let newValue {
                    Task {
                        if let imageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                            await MainActor.run {
                                selectedImage = image
                                showCropView.toggle()
                                photosItem = nil
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCropView) {
                selectedImage = nil
            } content: {
                CropView(image: selectedImage) { croppedImage, status in
                    DispatchQueue.main.async {
                        if let croppedImage {
                            self.croppedImage = croppedImage
                        }
                    }
                }
            }
    }
}

struct CropView: View {
    var image: UIImage?
    var onCrop: (UIImage?, Bool) -> ()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var dimOpacity: CGFloat = 0.65
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    var body: some View {
        NavigationStack {
            ImageView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.ignoresSafeArea())
                .overlay{
                    Grids()
                        .allowsHitTesting(false)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            /// Converting view to image
                            let renderer = ImageRenderer(content: ImageView(/*true*/))
                            renderer.proposedSize = .init(CGSize(width: 300, height: 300))
                            if let image = renderer.uiImage {
                                onCrop(image, true)
                            } else {
                                onCrop(nil, false)
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    func ImageView(/*_ hiddenGrids: Bool = false*/) -> some View {
        let cropSize = CGSize(width: 300, height: 300)
        GeometryReader {
            let size = $0.size
            
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        GeometryReader { proxy in
                            let rect = proxy.frame(in: .named("CROPVIEW"))
                            
                            Color.clear
                                .onChange(of: isInteracting) { _, newValue in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if rect.minX > 0 {
                                            offset.width = (offset.width - rect.minX)
                                            haptics(.medium)
                                        }
                                        if rect.minY > 0 {
                                            offset.height = (offset.height - rect.minY)
                                            haptics(.medium)
                                        }
                                        if rect.maxX < size.width {
                                            offset.width = (rect.minX - offset.width)
                                            haptics(.medium)
                                        }
                                        if rect.maxY < size.height {
                                            offset.height = (rect.minY - offset.height)
                                            haptics(.medium)
                                        }
                                    }
                                    
                                    if !newValue {
                                        lastStoredOffset = offset
                                    }
                                }
                        }
                    }
                    .frame(size)
            } else {
                Text("이미지 못찾음")
                    .foregroundStyle(.pink)
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .coordinateSpace(name: "CROPVIEW")
        .gesture(
            DragGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                    dimOpacity = 0.65
                })
                .onChanged({ value in
                    let translation = value.translation
                    offset = CGSize(
                        width: translation.width+lastStoredOffset.width,
                        height: translation.height + lastStoredOffset.height
                    )
                })
                .onEnded({ _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            dimOpacity = 0.9
                        }
                    }
                })
        )
        .gesture(
            MagnificationGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                    dimOpacity = 0.65
                })
                .onChanged({ value in
                    let updatedScale = value + lastScale
                    scale = (updatedScale < 1 ? 1 : updatedScale)
                })
                .onEnded({ value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if scale < 1 {
                            scale = 1
                            lastScale = 0
                        } else {
                            lastScale = scale - 1
                        }
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            dimOpacity = 0.9
                        }
                    }
                })
        )
        .frame(cropSize)
    }
    
    @ViewBuilder
    func Grids() -> some View {
        ZStack {
            Color.black.opacity(dimOpacity) // 전체 배경 색
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Circle()
                .frame(width: 300, height: 300)
                .blendMode(.destinationOut) // 원 내부를 투명하게 만듦
        }
        .compositingGroup() // 블렌드 모드 적용
    }
}


#Preview {
    CropView(image: UIImage(named: "img0")) { _, _ in }
}
