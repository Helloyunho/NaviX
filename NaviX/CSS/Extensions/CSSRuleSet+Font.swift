//
//  CSSRuleSet+Font.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation
import SwiftUI

extension CSSRuleSet {
    var fontSize: Int? {
        if let fontSize = properties["font-size"] {
            return cssUnitToInt(fontSize.first!)
        }
        return nil
    }
    
    var fontHeight: Int? { // wtf is this for real
        if let fontHeight = properties["font-height"] {
            return cssUnitToInt(fontHeight.first!)
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
