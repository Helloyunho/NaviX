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

    func findRuleset(for tag: any TagProtocol, html: HTMLTag? = nil) -> [CSSRuleSet] {
        var result = [CSSRuleSet]()
        for (selector, ruleset) in rulesets {
            if selector.children.count != 0 {
                if selector.children.contains(where: { $0.check(for: tag, html: html) }) {
                    result.append(ruleset)
                }
            } else {
                if selector.check(for: tag, html: html) {
                    result.append(ruleset)
                }
            }
        }

        return result
    }

    static func checkToken(_ token: CSSToken, type: CSSTokenType) throws {
        guard token.type == type else { throw CSSError.unexpectedToken(token.start, type) }
    }

    static func parse(_ css: String) throws -> CSSStylesheet {
        let tokens = try CSSToken.tokenize(css).filter { ![.comment, .commentMultiline].contains($0.type) }
        var idx = 0
        var token: CSSToken {
            tokens[idx]
        }
        var rulesets = [CSSSelector: CSSRuleSet]()
        while idx < tokens.count {
            let selector = try CSSSelector.parse(tokens: tokens, idx: &idx)
            try checkToken(token, type: .lbracket)
            let ruleset = try CSSRuleSet.parse(tokens: tokens, idx: &idx)
            try checkToken(token, type: .rbracket)
            rulesets[selector] = ruleset
        }

        return CSSStylesheet(rulesets: rulesets)
    }
}
