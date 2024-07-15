//
//  CSSStylesheet.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> String { String(self[index(startIndex, offsetBy: offset)]) }
}

struct CSSStylesheet {
    var rulesets: [CSSSelector: CSSRuleSet]

    func findRuleset(for tag: any TagProtocol, html: HTMLTag? = nil) async -> [CSSRuleSet] {
        var result = [CSSRuleSet]()
        for (selector, ruleset) in rulesets {
            if selector.children.count != 0 {
                for child in selector.children {
                    if await child.check(for: tag, html: html) {
                        result.append(ruleset)
                        break
                    }
                }
            } else {
                if await selector.check(for: tag, html: html) {
                    result.append(ruleset)
                }
            }
        }

        return result
    }

    static func checkToken(_ token: CSSToken, type: CSSTokenType) throws {
        guard token.type == type else {
            throw CSSError.unexpectedToken(token.start, type, token.type)
        }
    }

    static func parse(_ css: String) throws -> CSSStylesheet {
        let tokens = try CSSToken.tokenize(css).filter {
            ![.comment, .commentMultiline].contains($0.type)
        }
        var idx = 0
        var token: CSSToken {
            tokens[idx]
        }
        var rulesets = [CSSSelector: CSSRuleSet]()
        while idx < tokens.count {
            let selector = try CSSSelector.parse(tokens: tokens, idx: &idx)
            try checkToken(token, type: .lbracket)
            idx += 1
            let ruleset = try CSSRuleSet.parse(tokens: tokens, idx: &idx)
            try checkToken(token, type: .rbracket)
            idx += 1
            rulesets[selector] = ruleset
        }

        return CSSStylesheet(rulesets: rulesets)
    }
}
