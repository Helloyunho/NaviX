//
//  CSSSelector.swift
//  NaviX
//
//  Created by Helloyunho on 6/5/24.
//

import Foundation

struct CSSSelector: Hashable, Sendable {
    let tag: String
    let `class`: String
    let children: [CSSSelector]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
        hasher.combine(self.class)
        hasher.combine(children)
    }
    
    func check(for tag: any TagProtocol, html: HTMLTag? = nil) -> Bool {
        // for now html is not required
        tag.tagName == self.tag.lowercased() || tag.attr["class"]?.split(separator: " ").contains(where: { String($0) == self.class }) ?? false
    }
    
    private static func parseSingular(tokens: [CSSToken], idx: inout Int) throws -> CSSSelector {
        var tag = ""
        var c = ""
        var token: CSSToken {
            tokens[idx]
        }
        try CSSStylesheet.checkToken(token, type: .identifier)
        tag = token.value
        c = token.value // for now
        idx += 1
        
        return CSSSelector(tag: tag, class: c, children: [])
    }
    
    static func parse(tokens: [CSSToken]) throws -> CSSSelector {
        var idx = 0
        return try Self.parse(tokens: tokens, idx: &idx)
    }
    
    static func parse(tokens: [CSSToken], idx: inout Int) throws -> CSSSelector {
        var result: CSSSelector
        var token: CSSToken {
            tokens[idx]
        }
        
        let oneSelector = try parseSingular(tokens: tokens, idx: &idx)
        if token.type == .comma {
            var children = [oneSelector]
            while token.type == .comma {
                idx += 1
                try children.append(parseSingular(tokens: tokens, idx: &idx))
            }
            result = CSSSelector(tag: "", class: "", children: children)
        } else {
            result = oneSelector
        }
        
        return result
    }
}
