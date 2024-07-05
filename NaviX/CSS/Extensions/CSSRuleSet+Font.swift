//
//  CSSRuleSet+Font.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation
import SwiftUI

#if os(macOS)
extension NSFont {
    var lineHeight: CGFloat {
        (self.ascender + abs(self.descender) + self.leading).rounded(.up)
    }
}
#endif

extension CSSRuleSet {
    struct SingleOverlineShape: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.closeSubpath()
            }
        }
    }
    
    struct SingleUnderlineShape: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.closeSubpath()
            }
        }
    }
    
    struct DoubleUnderlineShape: Shape {
        let thickness: CGFloat = 2
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY + thickness * 2))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY + thickness * 2))
                path.closeSubpath()
            }
        }
    }
    
    struct LowUnderlineShape: Shape {
        let thickness: CGFloat = 2
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY + thickness))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY + thickness))
                path.closeSubpath()
            }
        }
    }
    
    struct StrikethroughShape: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                path.closeSubpath()
            }
        }
    }
    
    private struct FontOverlineModifier: ViewModifier {
        let overline: OverlineType
        let color: Color
        func body(content: Self.Content) -> some View {
            switch overline {
            case .single:
                content.overlay(SingleOverlineShape().stroke(color, lineWidth: 2))
            case .none:
                content
            }
        }
    }
    
    private struct FontUnderlineModifier: ViewModifier {
        let underline: UnderlineType
        let color: Color
        func body(content: Self.Content) -> some View {
            switch underline {
            case .single:
                content.overlay(SingleUnderlineShape().stroke(color, lineWidth: 2))
            case .double:
                content.overlay(DoubleUnderlineShape().stroke(color, lineWidth: 2))
            case .low:
                content.overlay(LowUnderlineShape().stroke(color, lineWidth: 2))
            case .error:
                content.overlay(SingleUnderlineShape().stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 6])))
            case .none:
                content
            }
        }
    }
    
    private struct FontStrikethroughModifier: ViewModifier {
        let strikethrough: Bool
        let color: Color
        func body(content: Self.Content) -> some View {
            if strikethrough {
                content.overlay(StrikethroughShape().stroke(color, lineWidth: 2))
            } else {
                content
            }
        }
    }
    
    struct CSSFontModifier: ViewModifier {
        let fontSize: Int
        let fontFamily: [String]
        let fontWeight: FontWeight
        let underline: UnderlineType
        let underlineColor: Color
        let overline: OverlineType
        let overlineColor: Color
        let strikethrough: Bool
        let strikethroughColor: Color
        let lineHeight: CGFloat?
        
        init(fontSize: Int?, fontFamily: [String]?, fontWeight: FontWeight?, underline: UnderlineType?, underlineColor: Color?, overline: OverlineType?, overlineColor: Color?, strikethrough: Bool?, strikethroughColor: Color?, lineHeight: CGFloat?) {
            self.fontSize = fontSize ?? 11
            self.fontFamily = fontFamily ?? []
            self.fontWeight = fontWeight ?? .normal
            self.underline = underline ?? .none
            self.underlineColor = underlineColor ?? .black
            self.overline = overline ?? .none
            self.overlineColor = overlineColor ?? .black
            self.strikethrough = strikethrough ?? false
            self.strikethroughColor = strikethroughColor ?? .black
            self.lineHeight = lineHeight
        }
        
        init(ruleSet: CSSRuleSet, defaultFontSize: Int = 11, defaultFontWeight: FontWeight = .normal, defaultUnderline: UnderlineType = .none, defaultUnderlineColor: Color = .black) {
            self.init(fontSize: ruleSet.fontSize ?? defaultFontSize, fontFamily: ruleSet.fontFamily, fontWeight: ruleSet.fontWeight ?? defaultFontWeight, underline: ruleSet.underline ?? defaultUnderline, underlineColor: ruleSet.underlineColor ?? defaultUnderlineColor, overline: ruleSet.overline, overlineColor: ruleSet.overlineColor, strikethrough: ruleSet.strikethrough, strikethroughColor: ruleSet.strikethroughColor, lineHeight: ruleSet.lineHeight == nil ? nil : CGFloat(ruleSet.lineHeight!))
        }
        
        func body(content: Self.Content) -> some View {
            Group {
                if let lineHeight {
                    content
                        .font(Font(font))
                        .lineSpacing(lineHeight - font.lineHeight)
                        .padding(.vertical, (lineHeight - font.lineHeight) / 2)
                } else {
                    content
                        .font(Font(font))
                }
            }
            .modifier(FontOverlineModifier(overline: overline, color: overlineColor))
            .modifier(FontUnderlineModifier(underline: underline, color: underlineColor))
            .modifier(FontStrikethroughModifier(strikethrough: strikethrough, color: strikethroughColor))
        }
        
        #if os(macOS)
        var font: NSFont {
            var font = NSFont.systemFont(ofSize: CGFloat(fontSize), weight: fontWeight.toNSFontWeight())
            let fontManager = NSFontManager.shared
            for family in fontFamily {
                guard fontManager.availableFontFamilies.contains(family), let families = fontManager.availableMembers(ofFontFamily: family), !families.isEmpty else { continue }
                font = NSFont(name: (families.first!.first as? String)!, size: CGFloat(fontSize))!
                for member in families {
                    if let fontName = member.first as? String, let fontWeight = member[1] as? String, fontWeight == self.fontWeight.rawValue.capitalized {
                        font = NSFont(name: fontName, size: CGFloat(fontSize))!
                        break
                    }
                }
                break
            }
            
            return font
        }
        #else
        var font: UIFont {
            var font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: fontWeight.toUIFontWeight())
            for family in fontFamily {
                guard UIFont.familyNames.contains(family) else { continue }
                let fontNames = UIFont.fontNames(forFamilyName: family)
                guard !fontNames.isEmpty else { continue }

                font = UIFont(name: fontNames.first!, size: CGFloat(fontSize))!
                for fontName in fontNames {
                    if fontName.contains("-\(fontWeight.rawValue.capitalized.replacingOccurrences(of: " ", with: ""))") {
                        font = UIFont(name: fontName, size: CGFloat(fontSize))!
                        break
                    }
                }
                break
            }
            return font
        }
        #endif
    }
    
    var fontSize: Int? {
        if let fontSize = properties["font-size"] {
            return cssUnitToInt(fontSize.first!)
        }
        return nil
    }
    
    var lineHeight: Int? { // wtf is this for real
        if let lineHeight = properties["line-height"] {
            return cssUnitToInt(lineHeight.first!)
        }
        return nil
    }
    
    var fontFamily: [String]? { // TODO: support generic-name values
        if let fontFamily = properties["font-family"] {
            return fontFamily
        }
        return nil
    }
    
    enum FontWeight: String {
        case ultralight
        case light
        case normal
        case bold
        case ultrabold
        case heavy
        
        func toSwiftUIWeight() -> SwiftUI.Font.Weight {
            switch self {
            case .ultralight:
                return .ultraLight
            case .light:
                return .light
            case .normal:
                return .regular
            case .bold:
                return .bold
            case .ultrabold:
                return .black
            case .heavy:
                return .heavy
            }
        }
        
        #if os(macOS)
        func toNSFontWeight() -> NSFont.Weight {
            switch self {
            case .ultralight:
                return .ultraLight
            case .light:
                return .light
            case .normal:
                return .regular
            case .bold:
                return .bold
            case .ultrabold:
                return .black
            case .heavy:
                return .heavy
            }
        }
        #else
        func toUIFontWeight() -> UIFont.Weight {
            switch self {
            case .ultralight:
                return .ultraLight
            case .light:
                return .light
            case .normal:
                return .regular
            case .bold:
                return .bold
            case .ultrabold:
                return .black
            case .heavy:
                return .heavy
            }
        }
        #endif
    }
    
    var fontWeight: FontWeight? {
        if let fontWeight = properties["font-weight"] {
            return FontWeight(rawValue: fontWeight.first!)
        }
        return nil
    }
    
    enum UnderlineType: String {
        case none
        case single
        case double
        case low
        case error
    }
    
    var underline: UnderlineType? {
        if let underline = properties["underline"] {
            return UnderlineType(rawValue: underline.first!)
        }
        return nil
    }
    
    var underlineColor: Color? {
        if let underlineColor = properties["underline-color"] {
            return cssColorToSwiftUI(underlineColor.first!)
        }
        return nil
    }
    
    enum OverlineType: String {
        case none
        case single
    }
    
    var overline: OverlineType? {
        if let overline = properties["overline"] {
            return OverlineType(rawValue: overline.first!)
        }
        return nil
    }
    
    var overlineColor: Color? {
        if let overlineColor = properties["overline-color"] {
            return cssColorToSwiftUI(overlineColor.first!)
        }
        return nil
    }
    
    var strikethrough: Bool? {
        if let strikethrough = properties["strikethrough"] {
            return strikethrough.first! == "true"
        }
        return nil
    }
    
    var strikethroughColor: Color? {
        if let color = properties["strikethrough-color"] {
            return cssColorToSwiftUI(color.first!)
        }
        return nil
    }
}
