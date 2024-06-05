//
//  CSSRuleSet.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftUI

struct CSSRuleSet {
    var properties = [String: [String]]()
    
    var color: Color? {
        if let color = properties["color"] {
            return cssColorToSwiftUI(color.first!)
        }
        return nil
    }
    
    var width: Int? {
        if let width = properties["width"] {
            return cssUnitToInt(width.first!)
        }
        return nil
    }
    
    var height: Int? {
        if let height = properties["height"] {
            return cssUnitToInt(height.first!)
        }
        return nil
    }
    
    internal func cssUnitToInt(_ unit: String) -> Int? {
        if unit.hasSuffix("px") || unit.hasSuffix("pt") {
            return Int(unit.prefix(upTo: unit.index(unit.endIndex, offsetBy: -2)))
        }
        return Int(unit)
    }
    
    internal enum Side: String {
        case top
        case right
        case bottom
        case left
    }
    
    internal func oneSideUnitToString(_ prefix: String, side: Side, suffix: String? = nil) -> String? {
        if let oneUnit = properties["\(prefix)-\(side.rawValue)\(suffix != nil ? "-suffix" : "")"] {
            return oneUnit.first!
        } else if let fourUnitsProp = properties["\(prefix)\(suffix != nil ? "-suffix" : "")"], let fourUnits = cssSideUnitsToString(fourUnitsProp) {
            switch side {
            case .top:
                return fourUnits.0
            case .right:
                return fourUnits.1
            case .bottom:
                return fourUnits.2
            case .left:
                return fourUnits.3
            }
        }
        return nil
    }
    
    /**
     - Returns: (top, right, bottom, left)
     */
    internal func cssSideUnitsToString(_ units: [String]) -> (String, String, String, String)? {
        if units.count == 1 {
            let value = units.first!
            return (value, value, value, value)
        } else if units.count == 2 {
            let vertical = units.first!
            let horizontal = units.last!
            return (vertical, horizontal, vertical, horizontal)
        } else if units.count == 3 {
            let top = units.first!
            let horizontal = units[1]
            let bottom = units.last!
            return (top, horizontal, bottom, horizontal)
        } else if units.count == 4 {
            let top = units.first!
            let right = units[1]
            let bottom = units[2]
            let left = units.last!
            return (top, right, bottom, left)
        }
        return nil
    }
    
    internal func oneSideUnitToInt(_ prefix: String, side: Side, suffix: String? = nil) -> Int? {
        if let oneUnit = properties["\(prefix)-\(side.rawValue)\(suffix != nil ? "-suffix" : "")"] {
            return cssUnitToInt(oneUnit.first!)
        } else if let fourUnitsProp = properties["\(prefix)\(suffix != nil ? "-suffix" : "")"], let fourUnits = cssSideUnitsToInt(fourUnitsProp) {
            switch side {
            case .top:
                return fourUnits.0
            case .right:
                return fourUnits.1
            case .bottom:
                return fourUnits.2
            case .left:
                return fourUnits.3
            }
        }
        return nil
    }
    
    /**
     - Returns: (top, right, bottom, left)
     */
    internal func cssSideUnitsToInt(_ units: [String]) -> (Int, Int, Int, Int)? {
        if units.count == 1 {
            let value = cssUnitToInt(units.first!)
            if let value {
                return (value, value, value, value)
            }
        } else if units.count == 2 {
            let vertical = cssUnitToInt(units.first!)
            let horizontal = cssUnitToInt(units.last!)
            if let vertical, let horizontal {
                return (vertical, horizontal, vertical, horizontal)
            }
        } else if units.count == 3 {
            let top = cssUnitToInt(units.first!)
            let horizontal = cssUnitToInt(units[1])
            let bottom = cssUnitToInt(units.last!)
            if let top, let horizontal, let bottom {
                return (top, horizontal, bottom, horizontal)
            }
        } else if units.count == 4 {
            let top = cssUnitToInt(units.first!)
            let right = cssUnitToInt(units[1])
            let bottom = cssUnitToInt(units[2])
            let left = cssUnitToInt(units.last!)
            if let top, let right, let bottom, let left {
                return (top, right, bottom, left)
            }
        }
        return nil
    }

    internal func cssColorToSwiftUI(_ color: String) -> Color {
        if color.starts(with: "#") {
            var hex = color
            hex.removeFirst()
            if let hexInt = Int(hex, radix: 16) {
                if hex.count == 8 {
                    return Color(red: Double((hexInt >> 24) & 0xFF) / 255, green: Double((hexInt >> 16) & 0xFF) / 255, blue: Double((hexInt >> 8) & 0xFF) / 255, opacity: Double(hexInt & 0xFF) / 255)
                } else if hex.count == 6 {
                    return Color(red: Double((hexInt >> 16) & 0xFF) / 255, green: Double((hexInt >> 8) & 0xFF) / 255, blue: Double(hexInt & 0xFF) / 255, opacity: 1.0)
                } else if hex.count == 3 {
                    return Color(red: Double((hexInt >> 8) & 0xF) / 255, green: Double((hexInt >> 4) & 0xF) / 255, blue: Double(hexInt & 0xF) / 255, opacity: 1.0)
                }
            }
        } else if let color = CSSColors[color] {
            return color
        }
        return Color(red: 0, green: 0, blue: 0)
    }

    static func + (lhs: CSSRuleSet, rhs: CSSRuleSet) -> CSSRuleSet {
        var copy = lhs
        for (key, value) in rhs.properties {
            copy.properties[key] = value
        }

        return copy
    }

    static func += (lhs: inout CSSRuleSet, rhs: CSSRuleSet) {
        lhs = lhs + rhs
    }

    static func parse(_ css: String) throws -> CSSRuleSet {
        let tokens = try CSSToken.tokenize(css)
        return try Self.parse(tokens: tokens)
    }

    static func parse(tokens: [CSSToken]) throws -> CSSRuleSet {
        var idx = 0
        return try Self.parse(tokens: tokens, idx: &idx)
    }

    static func parse(tokens: [CSSToken], idx: inout Int) throws -> CSSRuleSet {
        var key = ""
        var value = [String]()
        var properties = [String: [String]]()
        var token: CSSToken {
            tokens[idx]
        }
        while idx < tokens.count || token.type != .rbracket {
            try CSSStylesheet.checkToken(token, type: .identifier)
            key = token.value
            idx += 1
            try CSSStylesheet.checkToken(token, type: .comma)
            idx += 1
            while idx < tokens.count || token.type != .semi {
                if token.type == .comma {
                    idx += 1
                }
                try CSSStylesheet.checkToken(token, type: .identifier)
                value.append(token.value)
                idx += 1
            }
            idx += 1
            properties[key] = value
        }

        return CSSRuleSet(properties: properties)
    }
}
