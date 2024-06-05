//
//  CSSRuleSet+Border.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation
import SwiftUI

extension CSSRuleSet {
    var borderColor: Color? {
        if let borderColor = properties["border-color"] {
            return cssColorToSwiftUI(borderColor.first!)
        }
        return nil
    }

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
