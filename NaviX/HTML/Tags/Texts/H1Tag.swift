//
//  H1Tag.swift
//  NaviX
//
//  Created by Helloyunho on 6/4/24.
//

import Foundation
import SwiftSoup
import SwiftUI

struct H1Tag: BodyTagProtocol {
    let html: HTMLGetter
    let tagName = "h1"
    let id = UUID()

    var attr: [String: String] = [:] {
        didSet {
            NotificationCenter.default.post(name: .attrUpdated, object: self, userInfo: ["oldValue": oldValue])
        }
    }
    
    private var _children = [String]()

    var children: [any Content] {
        get {
            _children
        }
        set {
            let oldValue = _children
            _children = newValue.filter { $0 is String }.map { $0 as! String }
            NotificationCenter.default.post(name: .childrenUpdated, object: self, userInfo: ["oldValue": oldValue as Any])
        }
    }
    
    var style: CSSRuleSet {
        let html = self.html()
        var result = CSSRuleSet()
        for stylesheet in html.stylesheets {
            result += stylesheet.findRuleset(for: self, html: html).reduce(result, +)
        }
        if let css = attr["style"], let ruleset = try? CSSRuleSet.parse(css) {
            result += ruleset
        }

        return result
    }
    
    init(html: @escaping HTMLGetter, attr: [String : String], children: [any Content] = [any Content]()) {
        self.html = html
        self.attr = attr
        self.children = children
    }

    var body: some View {
        Text(_children.joined(separator: " "))
            .textSelection(.enabled)
            .modifier(CSSRuleSet.CSSFontModifier(ruleSet: style, defaultFontSize: 24, defaultFontWeight: .bold))
            .modifier(CSSRuleSet.CSSColorModifier(ruleSet: style))
            .applyCommonCSS(ruleSet: style, tag: self)
    }

    static func parse(_ elem: Element, html: @escaping HTMLGetter) throws -> H1Tag {
        try HTMLUtils.checkTag(elem, assert: "h1")
        let (attr, children) = Self.parseDefaultProps(elem, html: html)

        return H1Tag(html: html, attr: attr, children: children)
    }
}
