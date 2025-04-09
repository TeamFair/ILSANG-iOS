//
//  TagView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/3/24.
//

import SwiftUI

struct TagView: View {
    let title: String
    var image: ImageResource? = nil
    let tagStyle: TagStyle
    
    var body: some View {
        HStack(spacing: 0) {
            if let image = image {
                Image(image)
                    .resizable()
                    .frame(width: tagStyle.iconSize, height: tagStyle.iconSize)
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            Text(title)
                .multilineTextAlignment(.center)
        }
        .modifier(TagViewModifier(style: tagStyle))
    }
}

extension TagView {
    enum TagStyle {
        case level, levelStroke, xp, xpWithIcon, `repeat`(RepeatType), approvalType, eventWithIcon, eventDate
        
        var font: Font {
            switch self {
            case .level, .levelStroke: return .system(size: 13, weight: .bold)
            case .xpWithIcon, .eventDate: return .system(size: 12, weight: .regular)
            case .xp, .repeat, .approvalType, .eventWithIcon: return .system(size: 10, weight: .semibold)
            }
        }
        
        var fgColor: Color {
            switch self {
            case .level: return .white
            case .levelStroke: return .primaryPurple
            case .xp: return .white
            case .xpWithIcon: return .primaryPurple
            case .repeat(let type): return type.fgColor
            case .approvalType: return .white
            case .eventDate, .eventWithIcon: return .white
            }
        }
        
        var bgColor: Color {
            switch self {
            case .level: return .primaryPurple
            case .levelStroke: return .white
            case .xp: return .primaryPurple
            case .xpWithIcon: return .clear
            case .repeat: return .white
            case .approvalType: return .gray500
            case .eventDate, .eventWithIcon: return .primaryPurple
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
            case .xpWithIcon, .levelStroke: return .primaryPurple
            default: return nil
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .level: return EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12)
            case .levelStroke: return EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12)
            case .xp: return EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)
            case .xpWithIcon: return EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            case .repeat: return EdgeInsets(top: 0, leading: 11, bottom: 0, trailing: 11)
            case .eventDate: return EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
            case .eventWithIcon: return EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 6)
            case .approvalType: return EdgeInsets(top: 0, leading: 11, bottom: 0, trailing: 11)
            }
        }
        
        var height: CGFloat {
            switch self {
            case .level, .levelStroke, .xp, .repeat, .approvalType, .eventWithIcon:
                20
            case .xpWithIcon, .eventDate:
                25
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .eventWithIcon: 16
            case .xpWithIcon: 12
            default: 0
            }
        }
        
        var cornerRadius: CGFloat {
            return 16
        }
    }
}

struct TagViewModifier: ViewModifier {
    let style: TagView.TagStyle
    
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
