//
//  TagView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/3/24.
//

import SwiftUI

struct TagView<TrailingView: View>: View {
    let title: String
    var image: ImageResource? = nil
    let tagStyle: TagStyle
    let trailingView: TrailingView?
    
    init(
        title: String,
        image: ImageResource? = nil,
        tagStyle: TagStyle,
        @ViewBuilder trailingView: () -> TrailingView = { EmptyView() }
    ) {
        self.title = title
        self.image = image
        self.tagStyle = tagStyle
        self.trailingView = trailingView()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if let image {
                Image(image)
                    .resizable()
                    .frame(width: tagStyle.iconSize, height: tagStyle.iconSize)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            Text(title)
                .multilineTextAlignment(.center)
            if let trailingView {
                trailingView
            }
        }
        .modifier(TagViewModifier(style: tagStyle))
    }
}

enum TagStyle {
    case level, pointWithIcon, `repeat`(RepeatType), approvalType
    case levelStroke, levelStrokeBig
    case eventWithIcon
    var font: Font {
        switch self {
        case .level, .levelStroke: return .system(size: 13, weight: .bold)
        case .levelStrokeBig: return .system(size: 19, weight: .bold)
        case .pointWithIcon: return .system(size: 12, weight: .regular)
        case .repeat, .approvalType, .eventWithIcon: return .system(size: 10, weight: .semibold)
        }
    }
    
    var fgColor: Color {
        switch self {
        case .level: return .white
        case .levelStroke: return .primaryPurple
        case .levelStrokeBig: return .primaryPurple
        case .pointWithIcon: return .primaryPurple
        case .repeat(let type): return type.fgColor
        case .approvalType: return .white
        case .eventWithIcon: return .white
        }
    }
    
    var bgColor: Color {
        switch self {
        case .level: return .primaryPurple
        case .levelStroke: return .white
        case .levelStrokeBig: return .white
        case .pointWithIcon: return .clear
        case .repeat: return .white
        case .approvalType: return .gray500
        case .eventWithIcon: return .primaryPurple
        }
    }
    
    var gradient: Gradient? {
        switch self {
        case .repeat(let type): return type.bgGradient
        default: return nil
        }
    }
    
    var strokeColor: Color? {
        switch self {
        case .pointWithIcon, .levelStroke, .levelStrokeBig: return .primaryPurple
        default: return nil
        }
    }
    
    var padding: EdgeInsets {
        switch self {
        case .level: return EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12)
        case .levelStroke: return EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12)
        case .levelStrokeBig: return EdgeInsets(top: 6, leading: 21, bottom: 6, trailing: 21)
        case .pointWithIcon: return EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        case .repeat: return EdgeInsets(top: 0, leading: 11, bottom: 0, trailing: 11)
        case .eventWithIcon: return EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 6)
        case .approvalType: return EdgeInsets(top: 0, leading: 11, bottom: 0, trailing: 11)
        }
    }
    
    var height: CGFloat {
        switch self {
        case .level, .levelStroke, .repeat, .approvalType, .eventWithIcon:
            20
        case .pointWithIcon:
            25
        case .levelStrokeBig:
            30
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .eventWithIcon: 16
        case .pointWithIcon: 18
        default: 0
        }
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
}


struct TagViewModifier: ViewModifier {
    let style: TagStyle
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .foregroundColor(style.fgColor)
            .padding(style.padding)
            .frame(height: style.height)
            .background(
                ZStack {
                    if let gradient = style.gradient {
                        LinearGradient(
                            gradient: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        style.bgColor
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.strokeColor ?? .clear, lineWidth: 1)
            )
    }
}
