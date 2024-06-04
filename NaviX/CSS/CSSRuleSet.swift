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

    var borderColor: Color? {
        if let borderColor = properties["border-color"] {
            return cssColorToSwiftUI(borderColor.first!)
        }
        return nil
    }

    private func cssColorToSwiftUI(_ color: String) -> Color {
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
