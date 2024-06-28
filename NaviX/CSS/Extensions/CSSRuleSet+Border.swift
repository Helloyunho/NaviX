//
//  CSSRuleSet+Border.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation
import SwiftUI
import Kroma

extension CSSRuleSet {
    var borderColor: Color? {
        if let borderColor = properties["border-color"] {
            return cssColorToSwiftUI(borderColor.first!)
        }
        return nil
    }
    
    struct DoubleBorderShape: Shape {
        let width: CGFloat
        
        func path(in rect: CGRect) -> Path {
            let singleWidth = width / 3
            return Path { p in
                p.addRect(rect)
                p.addRect(rect.insetBy(dx: singleWidth*2, dy: singleWidth*2))
                p.closeSubpath()
            }
        }
    }
    
    struct DashedBorderShape: Shape {
        let dashLength: CGFloat
        let spaceLength: CGFloat

        func path(in rect: CGRect) -> Path {
            var path = Path()
            let sides = [
                (CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY)),
                (CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY)),
                (CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY)),
                (CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.minY))
            ]
            sides.forEach { (start, end) in
                let length = hypot(end.x - start.x, end.y - start.y)
                let (unitX, unitY) = ((end.x - start.x) / length, (end.y - start.y) / length)
                var (drawn, point, index) = (CGFloat(0), start, 0)
                
                while drawn < length {
                    if index % 2 == 0 {
                        path.move(to: point)
                        let next = CGPoint(x: point.x + unitX * min(dashLength, length - drawn), y: point.y + unitY * min(dashLength, length - drawn))
                        path.addLine(to: next)
                        point = next
                    } else {
                        point = CGPoint(x: point.x + unitX * min(spaceLength, length - drawn), y: point.y + unitY * min(spaceLength, length - drawn))
                    }
                    if index % 2 == 0 {
                        drawn += dashLength
                    } else {
                        drawn += spaceLength
                    }
                    index += 1
                }
            }
            path.closeSubpath()
            return path
        }
    }
    
    struct TopLeftBorderShape: Shape {
        let width: CGFloat

        func path(in rect: CGRect) -> Path {
            return Path { p in
                p.move(to: CGPoint(x: rect.minX, y: rect.minY))
                
                //top line
                p.addLine(to: CGPoint(x: rect.maxX - width, y: rect.minY))
                
                // Top-right corner
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                
                // Righ line
                p.addLine(to: CGPoint(x: rect.maxX - width, y: rect.minY + width))
                
                // Bottom-right corner
                p.addLine(to: CGPoint(x: rect.minX + width, y: rect.minY + width))
                
                // Bottom line
                p.addLine(to: CGPoint(x: rect.minX + width, y: rect.maxY - width))
                
                // Bottom-left corner
                p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                
                // Left line
                //p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + boundedCornerRadius))
                
                p.closeSubpath()
            }
        }
    }

    struct BottomRightBorderShape: Shape {
        let width: CGFloat

        func path(in rect: CGRect) -> Path {
            return Path { p in
                p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
                
                // Righ line
                p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY ))
                
                // Bottom line
                p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                
                // Bottom-left corner
                p.addLine(to: CGPoint(x: rect.minX + width, y: rect.maxY - width))
                
                //top line
                p.addLine(to: CGPoint(x: rect.maxX - width, y: rect.maxY - width))
                
                // Left line
                p.addLine(to: CGPoint(x: rect.maxX - width, y: rect.minY + width))
                
                p.closeSubpath()
            }
        }
    }
    
    struct ThreeDBorderOverlay: View {
        let type: BorderStyle
        let width: CGFloat
        let color: Color
        
        var body: some View {
            ZStack {
                if type == .groove {
                    apply3DEffect(color: color.darker(by: 0.3), colorOverlay: color)
                } else if type == .ridge {
                    apply3DEffect(color: color, colorOverlay: color.darker(by: 0.3))
                } else if type == .inset {
                    TopLeftBorderShape(width: width).fill(color.darker(by: 0.3))
                    BottomRightBorderShape(width: width).fill(color)
                } else if type == .outset {
                    TopLeftBorderShape(width: width).fill(color)
                    BottomRightBorderShape(width: width).fill(color.darker(by: 0.3))
                }
            }
        }
        
        private func apply3DEffect(color: Color, colorOverlay: Color) -> some View {
            ZStack {
                TopLeftBorderShape(width: width).fill(color)
                BottomRightBorderShape(width: width).fill(colorOverlay)
                TopLeftBorderShape(width: width / 2).fill(colorOverlay).padding(width / 2)
                BottomRightBorderShape(width: width / 2).fill(color).padding(width / 2)
            }
        }
    }
    
    struct CSSBorderModifier: ViewModifier {
        let borderColor: Color
        let borderWidth: CGFloat
        let borderRadius: CGFloat
        let borderStyle: BorderStyle
        
        init(borderColor: Color?, borderWidth: Int?, borderRadius: Int?, borderStyle: BorderStyle?) {
            self.borderColor = borderColor ?? .black
            self.borderWidth = CGFloat(borderWidth ?? 0)
            self.borderRadius = CGFloat(borderRadius ?? 0)
            self.borderStyle = borderStyle ?? .none
        }
        
        init(ruleSet: CSSRuleSet) {
            self.init(borderColor: ruleSet.borderColor, borderWidth: ruleSet.borderWidth.0, borderRadius: ruleSet.borderRadius, borderStyle: ruleSet.borderStyle.0)
        }
        
        func body(content: Self.Content) -> some View {
            if borderWidth == 0 {
                content
            } else {
                switch borderStyle {
                case .none:
                    content
                        .padding(borderWidth)
                        .clipShape(
                            RoundedRectangle(cornerRadius: borderRadius)
                        )
                case .dotted:
                    content
                        .overlay(
                            DashedBorderShape(dashLength: borderWidth, spaceLength: borderWidth)
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: borderRadius)
                        )
                case .dashed:
                    content
                        .overlay(
                            DashedBorderShape(dashLength: borderWidth*3, spaceLength: borderWidth*2)
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: borderRadius)
                        )
                case .solid:
                    content
                        .overlay(
                            Rectangle()
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: borderRadius))
                case .double:
                    content
                        .overlay(
                            DoubleBorderShape(width: borderWidth)
                                .stroke(borderColor, lineWidth: borderWidth / 3)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: borderRadius))
                case .groove, .ridge, .inset, .outset:
                    content
                        .overlay(
                            ThreeDBorderOverlay(type: borderStyle, width: borderWidth, color: borderColor)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: borderRadius))
                }
            }
        }
    }

    // TODO: support different border width/style/color/radius for each side
    var borderTopWidth: Int? {
        oneSideUnitToInt("border", side: .top, suffix: "width")
    }

    var borderRightWidth: Int? {
        oneSideUnitToInt("border", side: .right, suffix: "width")
    }

    var borderBottomWidth: Int? {
        oneSideUnitToInt("border", side: .bottom, suffix: "width")
    }

    var borderLeftWidth: Int? {
        oneSideUnitToInt("border", side: .left, suffix: "width")
    }

    /**
     - (top, right, bottom, left)
     */
    var borderWidth: (Int?, Int?, Int?, Int?) {
        var result: (Int?, Int?, Int?, Int?) = (nil, nil, nil, nil)

        if let borderTopWidth {
            result.0 = borderTopWidth
        }
        if let borderRightWidth {
            result.1 = borderRightWidth
        }
        if let borderBottomWidth {
            result.2 = borderBottomWidth
        }
        if let borderLeftWidth {
            result.3 = borderLeftWidth
        }

        return result
    }

    enum BorderStyle: String {
        case none
        case dotted
        case dashed
        case solid
        case double
        case groove
        case ridge
        case inset
        case outset
    }
    
    var borderTopStyle: BorderStyle? {
        if let borderTopStyle = oneSideUnitToString("border", side: .top, suffix: "style") {
            return BorderStyle(rawValue: borderTopStyle)
        }
        return nil
    }
    
    var borderRightStyle: BorderStyle? {
        if let borderRightStyle = oneSideUnitToString("border", side: .right, suffix: "style") {
            return BorderStyle(rawValue: borderRightStyle)
        }
        return nil
    }
    
    var borderBottomStyle: BorderStyle? {
        if let borderBottomStyle = oneSideUnitToString("border", side: .bottom, suffix: "style") {
            return BorderStyle(rawValue: borderBottomStyle)
        }
        return nil
    }
    
    var borderLeftStyle: BorderStyle? {
        if let borderLeftStyle = oneSideUnitToString("border", side: .left, suffix: "style") {
            return BorderStyle(rawValue: borderLeftStyle)
        }
        return nil
    }
    
    var borderStyle: (BorderStyle?, BorderStyle?, BorderStyle?, BorderStyle?) {
        var result: (BorderStyle?, BorderStyle?, BorderStyle?, BorderStyle?) = (nil, nil, nil, nil)

        if let borderTopStyle {
            result.0 = borderTopStyle
        }
        if let borderRightStyle {
            result.1 = borderRightStyle
        }
        if let borderBottomStyle {
            result.2 = borderBottomStyle
        }
        if let borderLeftStyle {
            result.3 = borderLeftStyle
        }

        return result
    }

    var borderRadius: Int? {
        if let borderRadius = properties["border-radius"] {
            return cssUnitToInt(borderRadius.first!)
        }
        return nil
    }
}
